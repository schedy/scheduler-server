class Execution < ActiveRecord::Base

	acts_as_seapig_dependency

	has_many :tasks
	has_many :execution_statuses
	has_one :status, ->{ where current: true }, class_name: "ExecutionStatus"
	belongs_to :user
	has_many :execution_values


	def self.create_with_tasks(data)
		execution = nil
		Execution.transaction {
			user_id = if data["creator"]
					  User.find_or_create_by!(nickname: data["creator"]).id
				  else
					  nil
				  end
			execution = Execution.create!(user_id: user_id)
			ExecutionStatus.create!(execution_id: execution.id, current: true, status: "waiting")
			(data["tags"] or {}).each_pair { |property_name, tag_names|
				tag_names.each { |value_name|
					property = Property.find_or_create_by!(name: property_name)
					value = Value.find_or_create_by!(property_id: property.id, value: value_name)
					execution_value = execution.execution_values.where(value_id: value.id).first
					execution_value = ExecutionValue.create!(execution_id: execution.id, value_id: value.id) if not execution_value
				}
			}
			data["tasks"].each { |task_params|
				task = Task.create!(execution_id: execution.id, description: task_params, )
				task_status = TaskStatus.create!(task_id: task.id, status: "waiting", current: true)
			}
			execution.update_status
			Execution.seapig_dependency_changed("Execution","Task","TaskStatus")
		}
		execution
	end

	
	def self.detailed_summary(options = {})

		query = [
			[ "SELECT json_build_object(                                                           ", "" ],
			[ "        'id', e.id,                                                                 ", "" ],
			[ "        'status', es.status,                                                        ", "" ],
			[ "        'duration', CASE WHEN es.status='finished' THEN date_trunc('second',(es.updated_at - e.created_at)) ELSE date_trunc('second',(now() - e.created_at)) END,", "" ],
			[ "        'creator', u.nickname,                                                      ", "" ],
			[ "        'created_at', e.created_at,                                                 ", "" ],
			[ "        'updated_at', e.updated_at,                                                 ", "" ],
			[ "        'tags', COALESCE(                                                           ", "" ],
			[ "                ( SELECT json_object_agg(tags.name, tags.values)                    ", "" ],
			[ "                  FROM (SELECT                                                      ", "" ],
			[ "                               p.name AS name,                                      ", "" ],
			[ "                               json_agg(v.value) AS values                          ", "" ],
			[ "                        FROM properties p, values v, execution_values ev            ", "" ],
			[ "                        WHERE v.property_id = p.id                                  ", "" ],
			[ "                              AND ev.value_id = v.id                                ", "" ],
			[ "                              AND ev.execution_id = e.id                            ", "" ],
			[ "                        GROUP BY p.name) AS tags                                    ", "" ],
			[ "                ), '[]'),                                                           ", "" ],
			[ "        'tasks', COALESCE(                                                          ", "" ],
			[ "                (  SELECT json_agg(json_build_object(                               ", "" ],
			[ "                        'id', t.id,                                                 ", "" ],
			[ "                        'status', ts.status                                         ", "" ],
			[ "                       ,'description', t.description,                               ", "task_details" ],
			[ "                        'created_at', date_trunc('second',t.created_at),                                 ", "task_details" ],
			[ "                        'status_changed_at', date_trunc('second',ts.created_at)                          ", "task_details" ],
			[ "                       ,'artifacts', COALESCE(                                      ", "artifacts" ],
			[ "                               (SELECT json_agg(json_build_object(                  ", "artifacts" ],
			[ "                                       'id', a.id,                                  ", "artifacts" ],
			[ "                                       'name', a.name,                              ", "artifacts" ],
			[ "                                       'mimetype', a.mimetype                       ", "artifacts" ],
			[ "                                       ) ORDER BY a.id )                            ", "artifacts" ],
			[ "                                FROM artifacts a                                    ", "artifacts" ],
			[ "                                WHERE a.task_id = t.id                              ", "artifacts" ],
			[ "                               ),'[]')                                              ", "artifacts" ],
			[ "                       ,'tags', COALESCE(                                           ", "task_details" ],
			[ "                               (SELECT json_object_agg(tags.name, tags.values)      ", "task_details" ],
			[ "                                FROM (SELECT                                        ", "task_details" ],
			[ "                                              p.name AS name,                       ", "task_details" ],
			[ "                                              json_agg(v.value) AS values           ", "task_details" ],
			[ "                                      FROM properties p, values v, task_values tv   ", "task_details" ],
			[ "                                      WHERE v.property_id = p.id                    ", "task_details" ],
			[ "                                            AND tv.value_id = v.id                  ", "task_details" ],
			[ "                                            AND tv.task_id = t.id                   ", "task_details" ],
			[ "                                      GROUP BY p.name) AS tags                      ", "task_details" ],
			[ "                                ), '[]')                                            ", "task_details" ],
			[ "                        ) ORDER BY t.id )                                           ", "" ],
			[ "                   FROM tasks t, task_statuses ts                                   ", "" ],
			[ "                   WHERE t.execution_id = e.id                                      ", "" ],
			[ "                           AND ts.task_id = t.id                                    ", "" ],
			[ "                           AND ts.current                                           ", "" ],
			[ "                ),'[]')                                                             ", "" ],
			[ "        ) AS description                                                            ", "" ],
			[ "FROM executions e                                                                   ", "" ],
			[ "        LEFT OUTER JOIN execution_statuses es ON e.id = es.execution_id             ", "" ],
			[ "        LEFT OUTER JOIN users u ON u.id = e.user_id                                 ", "" ],
			[ "WHERE                                                                               ", "" ],
			[ "        es.current AND                                                              ", "" ],
			[ (options[:conditions] or "true")                                                      , "" ],
			[ "ORDER BY e.id DESC                                                                  ", "" ],
			[ "LIMIT ?                                                                             ", "limit" ],
		].select { |line| ([""]+(options[:include] or [])).include? line[1] }.map { |line| line[0] }.join("\n")

		Execution.find_by_sql([query]+(options[:params] or []))
	end


	def update_status
		started = !! tasks.find { |task| not ['waiting'].include?(task.status.status) }
		all_done = ! tasks.find { |task| not ['finished','crashed','aborted','canceled'].include?(task.status.status) }
		p started, all_done
		new_status = {
			# started, all done         execution status
			[   false,    false    ] => "waiting",
			[   false,     true    ] => "finished",
			[    true,    false    ] => "running",
			[    true,     true    ] => "finished" }[[started, all_done]]
		if status.status != new_status
			status.update(current: false)
			ExecutionStatus.create!(execution_id: self.id, current: true, status: new_status)
		end
	end


end
