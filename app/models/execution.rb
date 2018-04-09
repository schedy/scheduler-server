
class Execution < ActiveRecord::Base

	has_many :tasks
	has_many :execution_statuses
	has_one :status, ->{ where current: true }, class_name: "ExecutionStatus"
	belongs_to :user
	has_many :execution_values
	has_many :execution_hooks
	has_many :artifacts


	def self.create_with_tasks(data)
		execution = nil
		Execution.transaction {
			user_id = if data["creator"]
				User.find_or_create_by!(nickname: data["creator"]).id
			else
				nil
			end

			execution = Execution.create!(user_id: user_id, data: data["data"])
			execution.with_lock {
				ExecutionStatus.create!(execution_id: execution.id, current: true, status: "waiting")

				properties = Hash.new {|h,k| h[k] = Property.find_or_create_by!(name: k) }
				values = Hash.new { |h,k| h[k] = Value.find_or_create_by!(property_id: k[0] , value: k[1]) }

				Task.create_from_description(execution, data["tasks"])

				(data["tags"] or {}).each_pair { |property_name, tag_names|
					tag_names.uniq.each { |value_name|
						property = properties[property_name]
						value = values[[property.id, value_name]]
						execution_value = ExecutionValue.create!(execution_id: execution.id, value_id: value.id, property_id: property.id)
					}
				}

				(data["hooks"] or {}).each_pair { |status, executables|
					executables.each { |executable|
						ExecutionHook.create!(execution_id: execution.id, status: status, hook: executable)
					}
				}

				SeapigDependency.bump("Execution","Task","Task:waiting",'Execution:%010i'%[execution.id])
			}

			execution.trigger_hooks("waiting")
			execution.update_status(true) if data["tasks"].blank?
		}
		execution
	end


	def duplicate_with_tasks
		duplicate_execution = self.dup
		self.transaction {
			duplicate_execution.save!
			duplicate_execution.with_lock {

				Task.create_from_description(duplicate_execution, self.tasks.map { |task| task.description.merge("requirements" => task.requirement.description) })

				self.execution_hooks.each { |hook|
					duplicate_hook = hook.dup
					duplicate_hook.save
					duplicate_execution.execution_hooks << duplicate_hook
				}

				self.execution_values.each { |execution_value|
					duplicate_execution_value = execution_value.dup
					duplicate_execution_value.save
					duplicate_execution.execution_values << duplicate_execution_value
				}

				duplicate_execution.save
				ExecutionStatus.create!(execution_id: duplicate_execution.id, current: true, status: "waiting")
				duplicate_execution.update_status(true)
			}
		}
		SeapigDependency.bump("Execution","Task","Task:waiting",'Execution:%010i'%[duplicate_execution.id])
		duplicate_execution
	end


	def self.detailed_summary(options = {})
		query = [
			[ "SELECT json_build_object(                                                                       ", "" ],
			[ "         'id', e.id,                                                                            ", "" ],
			[ "         'status', es.status,                                                                   ", "" ],
			[ "         'finished_at', CASE WHEN es.status='finished'                                          ", "" ],
			[ "                          THEN es.updated_at                                                    ", "" ],
			[ "                          ELSE NULL END,                                                        ", "" ],
			[ "         'creator', u.nickname,                                                                 ", "" ],
			[ "         'created_at', e.created_at,                                                            ", "" ],
			[ "         'updated_at', e.updated_at                                                             ", "" ],
			[ "         ,'hooks', COALESCE(                                                                    ", "hooks" ],
			[ "                            (SELECT json_agg(json_build_object(                                 ", "hooks" ],
			[ "                                    'id', h.id,                                                 ", "hooks" ],
			[ "                                    'hook', h.hook,                                             ", "hooks" ],
			[ "                                    'status', h.status                                          ", "hooks" ],
			[ "                                    ))                                                          ", "hooks" ],
			[ "                             FROM execution_hooks h                                             ", "hooks" ],
			[ "                             WHERE h.execution_id = e.id                                        ", "hooks" ],
			[ "                            ),'[]')                                                             ", "hooks" ],
			[ "         ,'artifacts', COALESCE(                                                                ", "artifacts" ],
			[ "                                (SELECT json_agg(json_build_object(                             ", "artifacts" ],
			[ "                                        'id', a.id,                                             ", "artifacts" ],
			[ "                                        'name', a.name,                                         ", "artifacts" ],
			[ "                                        'size', a.size,                                         ", "artifacts" ],
			[ "                                        'external_url', a.external_url,                         ", "artifacts" ],
			[ "                                        'mimetype', a.mimetype                                  ", "artifacts" ],
			[ "                                        ) ORDER BY a.name )                                     ", "artifacts" ],
			[ "                                 FROM artifacts a                                               ", "artifacts" ],
			[ "                                 WHERE a.execution_id = e.id                                    ", "artifacts" ],
			[ "                                ),'[]')                                                         ", "artifacts" ],
			[ "         ,'timeline', COALESCE(                                                                 ", "timeline" ],
			[ "                               (SELECT json_agg(t) AS times FROM                                ", "timeline" ],
			[ "                                       (SELECT w.name || ':' || r.remote_id as resource_id,     ", "timeline" ],
			[ "                                               rs1.id,                                          ", "timeline" ],
			[ "                                               rs1.task_id,                                     ", "timeline" ],
			[ "                                               rs1.created_at AS from,                          ", "timeline" ],
			[ "                                               (SELECT min(rs2.created_at)                      ", "timeline" ],
			[ "                                                FROM resource_statuses rs2                      ", "timeline" ],
			[ "                                                WHERE                                           ", "timeline" ],
			[ "                                                        rs1.created_at < rs2.created_at AND     ", "timeline" ],
			[ "                                                        rs1.resource_id = rs2.resource_id AND   ", "timeline" ],
			[ "                                                        rs2.task_id is null ) AS to             ", "timeline" ],
			[ "                                        FROM resource_statuses rs1, tasks t,                    ", "timeline" ],
			[ "                                             resources r, workers w                             ", "timeline" ],
			[ "                                        WHERE t.id = rs1.task_id and t.execution_id = e.id      ", "timeline" ],
			[ "                                              AND rs1.resource_id = r.id AND r.worker_id = w.id ", "timeline" ],
			[ "                                        ORDER BY rs1.created_at) t                              ", "timeline" ],
			[ "                                ),'[]')                                                         ", "timeline" ],
			[ "         ,'tags', COALESCE(                                                                     ", "tags" ],
			[ "                 ( SELECT json_object_agg(tags.name, tags.values)                               ", "tags" ],
			[ "                   FROM (SELECT                                                                 ", "tags" ],
			[ "                                p.name AS name,                                                 ", "tags" ],
			[ "                                json_agg(v.value ORDER BY v.value) AS values                    ", "tags" ],
			[ "                         FROM properties p, values v, execution_values ev                       ", "tags" ],
			[ "                         WHERE ev.property_id = p.id                                            ", "tags" ],
			[ "                               AND ev.value_id = v.id                                           ", "tags" ],
			[ "                               AND ev.execution_id = e.id                                       ", "tags" ],
			[ "                         GROUP BY p.name                                                        ", "tags" ],
			[ "                         ORDER BY p.name) AS tags                                               ", "tags" ],
			[ "                 ), '[]')                                                                       ", "tags" ],
			[ "         ,'task_statuses', COALESCE(                                                            ", "task_statuses" ],
			[ "                 (  SELECT json_object_agg(x.key, x.value) FROM                                 ", "task_statuses" ],
			[ "                           (          SELECT                                                    ", "task_statuses" ],
			[ "                                      ts.status as key,                                         ", "task_statuses" ],
			[ "                                      count(*) as value                                         ", "task_statuses" ],
			[ "                              FROM tasks t, task_statuses ts                                    ", "task_statuses" ],
			[ "                              WHERE                                                             ", "task_statuses" ],
			[ "                                     t.execution_id = e.id AND                                  ", "task_statuses" ],
			[ "                                     ts.current AND                                             ", "task_statuses" ],
			[ "                                     ts.task_id = t.id                                          ", "task_statuses" ],
			[ "                              GROUP BY ts.status) x                                             ", "task_statuses" ],
			[ "                 ), '[]')                                                                       ", "task_statuses" ],
			[ "         ,'tasks', COALESCE(                                                                    ", "task" ],
			[ "                 (  SELECT json_agg(json_build_object(                                          ", "task" ],
			[ "                         'id', t.id,                                                            ", "task" ],
			[ "                         'status', ts.status                                                    ", "task" ],
			[ "                        ,'worker', w.name                                                       ", "task_worker" ],
			[ "                        ,'resources', COALESCE(                                                 ", "task_resources" ],
			[ "                                (SELECT  json_agg(x.resource)                                   ", "task_resources" ],
			[ "                                 FROM                                                           ", "task_resources" ],
			[ "                                       (SELECT DISTINCT ON (r.remote_id) json_build_object(     ", "task_resources" ],
			[ "                                               'id', rs.resource_id,                            ", "task_resources" ],
			[ "                                               'remote_id', r.remote_id) AS resource            ", "task_resources" ],
			[ "                                        FROM resource_statuses rs, resources r                  ", "task_resources" ],
			[ "                                        WHERE                                                   ", "task_resources" ],
			[ "                                               rs.task_id = t.id AND                            ", "task_resources" ],
			[ "                                               rs.resource_id = r.id                            ", "task_resources" ],
			[ "                                        ORDER BY r.remote_id                                    ", "task_resources" ],
			[ "                                        ) x                                                     ", "task_resources" ],
			[ "                                ),'[]')                                                         ", "task_resources" ],
			[ "                        ,'description', t.description,                                          ", "task_description" ],
			[ "                        ,'artifacts', COALESCE(                                                 ", "task_artifacts" ],
			[ "                                (SELECT json_agg(json_build_object(                             ", "task_artifacts" ],
			[ "                                        'id', a.id,                                             ", "task_artifacts" ],
			[ "                                        'name', a.name,                                         ", "task_artifacts" ],
			[ "                                        'mimetype', a.mimetype                                  ", "task_artifacts" ],
			[ "                                        ) ORDER BY a.id )                                       ", "task_artifacts" ],
			[ "                                 FROM artifacts a                                               ", "task_artifacts" ],
			[ "                                 WHERE a.task_id = t.id                                         ", "task_artifacts" ],
			[ "                                ),'[]')                                                         ", "task_artifacts" ],
			[ "                        ,'tags', COALESCE(                                                      ", "task_tags" ],
			[ "                                (SELECT json_object_agg(tags.name, tags.values)                 ", "task_tags" ],
			[ "                                 FROM (SELECT                                                   ", "task_tags" ],
			[ "                                               p.name AS name,                                  ", "task_tags" ],
			[ "                                               json_agg(v.value ORDER BY v.value) AS values     ", "task_tags" ],
			[ "                                       FROM properties p, values v, task_values tv              ", "task_tags" ],
			[ "                                       WHERE tv.property_id = p.id                              ", "task_tags" ],
			[ "                                             AND tv.value_id = v.id                             ", "task_tags" ],
			[ "                                             AND tv.task_id = t.id                              ", "task_tags" ],
			[ "                                       GROUP BY p.name                                          ", "task_tags" ],
			[ "                                       ORDER BY p.name) AS tags                                 ", "task_tags" ],
			[ "                                 ), '[]')                                                       ", "task_tags" ],
			[ "                         ) ORDER BY t.id )                                                      ", "task" ],
			[ "                    FROM tasks t, task_statuses ts                                              ", "task" ],
			[ "                         LEFT OUTER JOIN workers w ON w.id = ts.worker_id                       ", "task_worker" ],
			[ "                    WHERE t.execution_id = e.id                                                 ", "task" ],
			[ "                            AND ts.task_id = t.id                                               ", "task" ],
			[ "                            AND ts.current                                                      ", "task" ],
			[ "                            AND NOT EXISTS (SELECT 1                                            ", "task_filter" ],
			[ "                                            FROM task_values tv                                 ", "task_filter" ],
			[ "                                            WHERE tv.task_id = t.id AND tv.value_id IN (?))     ", "task_filter" ],
			[ "                            AND (SELECT count(distinct tv.property_id)                          ", "task_filter" ],
			[ "                                            FROM task_values tv                                 ", "task_filter" ],
			[ "                                            WHERE tv.task_id = t.id                             ", "task_filter" ],
			[ "                                                  AND tv.property_id IN (?)) = ?                ", "task_filter" ],
			[ "                 ),'[]')                                                                        ", "task" ],
			[ "         ,'task_tag_stats', COALESCE(                                                           ", "task_tag_stats" ],
			[ "                 (SELECT json_object_agg(c.property, c.counts)                                  ", "task_tag_stats" ],
			[ "                  FROM (SELECT                                                                  ", "task_tag_stats" ],
			[ "                                cfa.property,                                                   ", "task_tag_stats" ],
			[ "                                json_object_agg(cfa.value, cfa.count) AS counts                 ", "task_tag_stats" ],
			[ "                        FROM (SELECT p.name AS property, v.value AS value, count(*)             ", "task_tag_stats" ],
			[ "                              FROM values v, task_values tv , properties p                      ", "task_tag_stats" ],
			[ "                              WHERE                                                             ", "task_tag_stats" ],
			[ "                                      tv.property_id = p.id AND                                 ", "task_tag_stats" ],
			[ "                                      tv.value_id = v.id AND                                    ", "task_tag_stats" ],
			[ "                                      tv.task_id IN (SELECT t.id                                ", "task_tag_stats" ],
			[ "                                                     FROM tasks t                               ", "task_tag_stats" ],
			[ "                                                     WHERE t.execution_id = e.id)               ", "task_tag_stats" ],
			[ "                              GROUP BY p.name, v.value                                          ", "task_tag_stats" ],
			[ "                              ORDER BY p.name, v.value) AS cfa                                  ", "task_tag_stats" ],
			[ "                        GROUP BY cfa.property) AS c                                             ", "task_tag_stats" ],
			[ "                  WHERE c.counts IS NOT NULL                                                    ", "task_tag_stats" ],
			[ "                 ),'[]')                                                                        ", "task_tag_stats" ],
			[ "         ) AS description                                                                       ", "" ],
			[ "FROM                                                                                            ", "" ],
			[ "         (SELECT * FROM executions                                                              ", "" ],
			[ "                   WHERE                                                                        ", "" ],
			[ (options[:conditions] or "true")                                                                  , "" ],
			[ "                   ORDER BY executions.id DESC                                                  ", "" ],
			[ "                   LIMIT ?                                                                      ", "limit" ],
			[ "                   ) e                                                                          ", "" ],
			[ "         LEFT OUTER JOIN execution_statuses es ON e.id = es.execution_id                        ", "" ],
			[ "         LEFT OUTER JOIN users u ON u.id = e.user_id                                            ", "" ],
			[ "WHERE                                                                                           ", "" ],
			[ "         es.current                                                                             ", "" ],
			[ "ORDER BY e.id DESC										   ", "" ]
		].select { |line| ([""]+(options[:include] or [])).include? line[1] }.map { |line| line[0] }.join("\n")

		Execution.find_by_sql([query]+(options[:params] or []))
	end


	def trigger_hooks(status)
		self.execution_hooks.where(status: status).each { |hook|
			`unset BUNDLE_GEMFILE; cd project/hooks/ ; nohup ./#{hook.hook} #{self.id} #{status} 1>>../../log/#{hook.hook}.log 2>&1 &`  #FIXME: vailidate, escape, etc.
		}
	end


	def update_status(is_locked)
		update = lambda {
			started = ((Task.joins("LEFT JOIN task_statuses ON task_statuses.task_id = tasks.id").where("tasks.execution_id = ? AND task_statuses.current AND NOT task_statuses.status = 'waiting'",id).count or 0) > 0)
			all_done = ((Task.joins("LEFT JOIN task_statuses ON task_statuses.task_id = tasks.id").where("tasks.execution_id = ? AND task_statuses.current AND NOT task_statuses.status IN ('finished','crashed','aborted','cancelled','failed','timeout')",id).count or 0) == 0)
			new_status = {
				# started,   all done,	   execution status
				[   false,	false ] => "waiting",
				[   false,	 true ] => "finished",
				[    true,	false ] => "running",
				[    true,	 true ] => "finished" }[[started, all_done]]
			if status.status != new_status
				status.update(current: false)
				ExecutionStatus.create!(execution_id: self.id, current: true, status: new_status)
				trigger_hooks(new_status)
			end
		}
		if is_locked then update.call else with_lock(&update) end
	end
end
