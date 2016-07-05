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

      ExecutionStatus.create!(execution_id: execution.id, current: true, status: "waiting")
      (data["tags"] or {}).each_pair { |property_name, tag_names|
        tag_names.each { |value_name|
          property = Property.find_or_create_by!(name: property_name)
          value = Value.find_or_create_by!(property_id: property.id, value: value_name)
          execution_value = execution.execution_values.where(value_id: value.id).first
          execution_value = ExecutionValue.create!(execution_id: execution.id, value_id: value.id) if not execution_value
        }
      }
      (data["tasks"] or []).each { |task_params|

        task = Task.create!(execution_id: execution.id, description: task_params )
        task_status = TaskStatus.create!(task_id: task.id, status: "waiting", current: true)
      }

      (data["hooks"] or {}).each_pair { |status, executables|
        executables.each { |executable|
          ExecutionHook.create!(execution_id: execution.id, status: status, hook: executable)
        }
      }

      execution.update_status
      SeapigDependency.bump("Execution","Task","TaskStatus")
    }
    execution
  end


  def self.detailed_summary(options = {})

    query = [
      [ "SELECT json_build_object(                                                                     ", "" ],
      [ "        'id', e.id,                                                                           ", "" ],
      [ "        'status', es.status,                                                                  ", "" ],
      [ "        'duration', CASE WHEN es.status='finished'                                            ", "" ],
      [ "                         THEN date_trunc('second',(es.updated_at - e.created_at))             ", "" ],
      [ "                         ELSE date_trunc('second',(now() - e.created_at)) END,                ", "" ],
      [ "        'creator', u.nickname,                                                                ", "" ],
      [ "        'created_at', e.created_at,                                                           ", "" ],
      [ "        'updated_at', e.updated_at,                                                           ", "" ],

      [ "        'artifacts', COALESCE(                                                                ", "artifacts" ],
      [ "                               (SELECT json_agg(json_build_object(                            ", "artifacts" ],
      [ "                                       'id', a.id,                                            ", "artifacts" ],
      [ "                                       'name', a.name,                                        ", "artifacts" ],
      [ "                                       'mimetype', a.mimetype                                 ", "artifacts" ],
      [ "                                       ) ORDER BY a.id )                                      ", "artifacts" ],
      [ "                                FROM artifacts a                                              ", "artifacts" ],
      [ "                                WHERE a.execution_id = e.id                                   ", "artifacts" ],
      [ "                               ),'[]'),                                                       ", "artifacts" ],


      [ "        'timeline', COALESCE(                                                                 ", "timeline" ],
      [ "        (SELECT json_agg(t) AS times FROM                                                     ", "timeline" ],
      [ "                (SELECT rs1.resource_id, rs1.task_id,                                         ", "timeline" ],
      [ "                rs1.created_at AS from,min(rs2.created_at) AS to                              ", "timeline" ],
      [ "        FROM resource_statuses rs1, resource_statuses rs2, tasks t                            ", "timeline" ],
      [ "        WHERE rs1.created_at < rs2.created_at                                                 ", "timeline" ],
      [ "            AND rs2.task_id IS null AND rs1.task_id IS NOT null                               ", "timeline" ],
      [ "            AND rs1.resource_id = rs2.resource_id AND rs1.task_id = t.id                      ", "timeline" ],
      [ "            AND t.execution_id = e.id                                                         ", "timeline" ],
      [ "        GROUP BY rs1.resource_id,rs1.task_id,rs1.created_at) t                                ", "timeline" ],
      [ "                               ),'[]'),                                                       ", "timeline" ],

      [ "        'tags', COALESCE(                                                                     ", "" ],
      [ "                ( SELECT json_object_agg(tags.name, tags.values)                              ", "" ],
      [ "                  FROM (SELECT                                                                ", "" ],
      [ "                               p.name AS name,                                                ", "" ],
      [ "                               json_agg(v.value ORDER BY v.value) AS values                   ", "" ],
      [ "                        FROM properties p, values v, execution_values ev                      ", "" ],
      [ "                        WHERE v.property_id = p.id                                            ", "" ],
      [ "                              AND ev.value_id = v.id                                          ", "" ],
      [ "                              AND ev.execution_id = e.id                                      ", "" ],
      [ "                        GROUP BY p.name                                                       ", "" ],
      [ "                        ORDER BY p.name) AS tags                                              ", "" ],
      [ "                ), '[]'),                                                                     ", "" ],
      [ "        'tasks', COALESCE(                                                                    ", "" ],
      [ "                (  SELECT json_agg(json_build_object(                                         ", "" ],
      [ "                        'id', t.id,                                                           ", "" ],
      [ "                        'status', ts.status                                                   ", "" ],
      [ "                       ,'description', t.description,                                         ", "task_details" ],
      [ "                        'created_at', date_trunc('second',t.created_at),                      ", "task_details" ],
      [ "                        'status_changed_at', date_trunc('second',ts.created_at)               ", "task_details" ],
      [ "                       ,'artifacts', COALESCE(                                                ", "task_artifacts" ],
      [ "                               (SELECT json_agg(json_build_object(                            ", "task_artifacts" ],
      [ "                                       'id', a.id,                                            ", "task_artifacts" ],
      [ "                                       'name', a.name,                                        ", "task_artifacts" ],
      [ "                                       'mimetype', a.mimetype                                 ", "task_artifacts" ],
      [ "                                       ) ORDER BY a.id )                                      ", "task_artifacts" ],
      [ "                                FROM artifacts a                                              ", "task_artifacts" ],
      [ "                                WHERE a.task_id = t.id                                        ", "task_artifacts" ],
      [ "                               ),'[]')                                                        ", "task_artifacts" ],
      [ "                       ,'tags', COALESCE(                                                     ", "task_details" ],
      [ "                               (SELECT json_object_agg(tags.name, tags.values)                ", "task_details" ],
      [ "                                FROM (SELECT                                                  ", "task_details" ],
      [ "                                              p.name AS name,                                 ", "task_details" ],
      [ "                                              json_agg(v.value ORDER BY v.value) AS values    ", "task_details" ],
      [ "                                      FROM properties p, values v, task_values tv             ", "task_details" ],
      [ "                                      WHERE v.property_id = p.id                              ", "task_details" ],
      [ "                                            AND tv.value_id = v.id                            ", "task_details" ],
      [ "                                            AND tv.task_id = t.id                             ", "task_details" ],
      [ "                                      GROUP BY p.name                                         ", "task_details" ],
      [ "                                      ORDER BY p.name) AS tags                                ", "task_details" ],
      [ "                                ), '[]')                                                      ", "task_details" ],
      [ "                        ) ORDER BY t.id )                                                     ", "" ],
      [ "                   FROM tasks t, task_statuses ts                                             ", "" ],
      [ "                   WHERE t.execution_id = e.id                                                ", "" ],
      [ "                           AND ts.task_id = t.id                                              ", "" ],
      [ "                           AND ts.current                                                     ", "" ],
      [ "                ),'[]')                                                                       ", "" ],
      [ "        ,'task_tag_stats', COALESCE(                                                          ", "task_details" ],
      [ "                (SELECT json_object_agg(c.property, c.counts)                                 ", "task_details" ],
      [ "                 FROM (SELECT                                                                 ", "task_details" ],
      [ "                               cfa.property,                                                  ", "task_details" ],
      [ "                               json_object_agg(cfa.value, cfa.count) AS counts                ", "task_details" ],
      [ "                       FROM (SELECT p.name AS property, v.value AS value, count(*)            ", "task_details" ],
      [ "                             FROM values v, task_values tv , properties p                     ", "task_details" ],
      [ "                             WHERE                                                            ", "task_details" ],
      [ "                                     v.id = tv.value_id AND                                   ", "task_details" ],
      [ "                                     v.property_id = p.id AND                                 ", "task_details" ],
      [ "                                     tv.value_id = v.id AND                                   ", "task_details" ],
      [ "                                     tv.task_id IN (SELECT t.id                               ", "task_details" ],
      [ "                                                    FROM tasks t                              ", "task_details" ],
      [ "                                                    WHERE t.execution_id = e.id)              ", "task_details" ],
      [ "                             GROUP BY p.name, v.value                                         ", "task_details" ],
      [ "                             ORDER BY p.name, v.value) AS cfa                                 ", "task_details" ],
      [ "                       GROUP BY cfa.property) AS c                                            ", "task_details" ],
      [ "                 WHERE c.counts IS NOT NULL                                                   ", "task_details" ],
      [ "                ),'[]')                                                                       ", "task_details" ],
      [ "        ) AS description                                                                      ", "" ],
      [ "FROM executions e                                                                             ", "" ],
      [ "        LEFT OUTER JOIN execution_statuses es ON e.id = es.execution_id                       ", "" ],
      [ "        LEFT OUTER JOIN users u ON u.id = e.user_id                                           ", "" ],
      [ "WHERE                                                                                         ", "" ],
      [ "        es.current AND                                                                        ", "" ],
      [ (options[:conditions] or "true")                                                                , "" ],
      [ "ORDER BY e.id DESC                                                                            ", "" ],
      [ "LIMIT ?                                                                                       ", "limit" ],
    ].select { |line| ([""]+(options[:include] or [])).include? line[1] }.map { |line| line[0] }.join("\n")

    Execution.find_by_sql([query]+(options[:params] or []))
  end


  def update_status
    started = !! tasks.find { |task| not ['waiting'].include?(task.status.status) }
    all_done = ! tasks.find { |task| not ['finished','crashed','aborted','cancelled','failed'].include?(task.status.status) }
    p started, all_done
    new_status = {
      # started, all done         execution status
      [   false,    false    ] => "waiting",
      [   false,     true    ] => "finished",
      [    true,    false    ] => "running",
      [    true,     true    ] => "finished" }[[started, all_done]]
    if status.status != new_status
      #			ExecutionStatus.transaction {
      status.update(current: false)
      ExecutionStatus.create!(execution_id: self.id, current: true, status: new_status)
      #			}
      self.execution_hooks.where(status: new_status).each { |hook|
        `unset BUNDLE_GEMFILE; cd project/hooks/ ; nohup ./#{hook.hook} #{self.id} #{new_status} 1>>../../log/#{hook.hook}.log 2>&1 &`
      }
    end
  end


end
