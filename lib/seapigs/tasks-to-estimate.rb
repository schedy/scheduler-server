require './config/environment.rb'

class TaskToEstimate < Producer
	@patterns = [ 'tasks-to-estimate' ]

	def self.produce(seapig_object_id)

		#ActiveRecord::Base.logger = Logger.new(STDERR)
		Task.uncached {
			version = SeapigDependency.versions('Task:waiting')
			Task.connection.execute("CREATE TEMPORARY TABLE pg_planner_go_home_you_re_drunk AS SELECT task_statuses.task_id FROM task_statuses WHERE task_statuses.current AND task_statuses.status = 'waiting' UNION ALL SELECT task_statuses.task_id FROM task_statuses WHERE task_statuses.current AND task_statuses.status = 'assigned' AND task_statuses.created_at < now()-'20s'::interval")
			data =  Task.find_by_sql(
					"select json_object_agg(x.id, x.req) as summary from (
					        select r.id as id, json_build_object('requirements',r.description,'tasks',json_object_agg(t.id, json_build_object('duration-key',array[t.description ->> 'test_name',t.description ->> 'test_environment']))) as req
					        from requirements r, tasks t, pg_planner_go_home_you_re_drunk ti
					        where t.id = ti.task_id and t.requirement_id = r.id group by r.id
					) as x;"
				)[0].summary
			
			Task.connection.execute('DROP TABLE pg_planner_go_home_you_re_drunk')
			[data, version]
		}
	end
end

#					"with tids as
#					        (SELECT task_statuses.task_id FROM  task_statuses WHERE task_statuses.current  AND task_statuses.status = 'waiting'
#					         UNION ALL SELECT task_statuses.task_id FROM  task_statuses WHERE task_statuses.current  AND (task_statuses.status = 'assigned' AND task_statuses.created_at < (now()-'20 seconds'::interval)))
#					select json_object_agg(x.id, x.req) as summary from (
#					        select r.id as id, json_build_object('requirements',r.description,'tasks',json_agg(json_build_object('id',t.id,'duration-key',t.description ->> 'test_name'))) as req
#					        from requirements r, tasks t, tids ti
#					        where t.id = ti.task_id and t.requirement_id = r.id group by r.id
#					) as x;"

#					"select json_object_agg(x.id, x.req) as summary from (
#				        select r.id as id, json_build_object('requirements',r.description,'tasks',json_agg(json_build_object('id',t.id,'duration-key',t.description ->> 'test_name'))) as req
#					        from requirements r, tasks t, pg_planner_go_home_you_re_drunk ti
#					        where t.id = ti.task_id and t.requirement_id = r.id group by r.id
#					) as x;"
