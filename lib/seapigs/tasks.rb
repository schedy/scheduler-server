require './config/environment.rb'

class Tasks < Producer

	@patterns = [ 'tasks-waiting' ]

	def self.produce(seapig_object_id)

		#ActiveRecord::Base.logger = Logger.new(STDERR)

		Task.uncached {
			version = SeapigDependency.versions('Task:waiting')
			Task.connection.execute("CREATE TEMPORARY TABLE pg_planner_go_home_you_re_drunk AS SELECT task_statuses.task_id FROM task_statuses WHERE task_statuses.current AND task_statuses.status = 'waiting' UNION ALL SELECT task_statuses.task_id FROM task_statuses WHERE task_statuses.current AND task_statuses.status = 'assigned' AND task_statuses.created_at < now()-'20s'::interval")
			data = {
				tasks: Task.where('tasks.id in (SELECT task_id FROM pg_planner_go_home_you_re_drunk)').sort_by { |task| task.id.to_i }.map { |task|
					task.description.merge(id: task.id, execution_id: task.execution_id)
				}
			}
			Task.connection.execute('DROP TABLE pg_planner_go_home_you_re_drunk')
			[data, version]
		}

	end

end
