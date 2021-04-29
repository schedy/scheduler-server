require './config/environment.rb'

class TaskToDeal < Producer

	@patterns = [ 'tasks-to-deal' ]

	def self.produce(seapig_object_id)

		#ActiveRecord::Base.logger = Logger.new(STDERR)
		Task.uncached {
			version = SeapigDependency.versions('Task:waiting')
			Task.connection.execute("CREATE TEMPORARY TABLE pg_planner_go_home_you_re_drunk AS SELECT task_statuses.task_id FROM task_statuses WHERE task_statuses.current AND task_statuses.status = 'waiting' UNION ALL SELECT task_statuses.task_id FROM task_statuses WHERE task_statuses.current AND task_statuses.status = 'assigned' AND task_statuses.created_at < now()-'20s'::interval")
			data = {
				tasks: (Task.find_by_sql(
					"select json_object_agg(x.id, x.task) as summary from
					         (select t.id as id, json_build_object(
                             'execution_id',t.execution_id ,
                             'priority', t.description->>'priority',
                             'actor_count', jsonb_array_length(r.description)
                             ) as task
					          from tasks t, requirements r, pg_planner_go_home_you_re_drunk ti where t.id = ti.task_id and r.id = t.requirement_id
					) as x;"
				)[0].summary or {})
			}
			Task.connection.execute('DROP TABLE pg_planner_go_home_you_re_drunk')
			[data, version]
		}
	end

end
