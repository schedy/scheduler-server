require './config/environment.rb'

class Assignments < Producer

	@patterns = [ 'assignments:*' ]

	def self.produce(seapig_object_id)

		#ActiveRecord::Base.logger = Logger.new(STDERR)

		Task.uncached {
			seapig_object_id =~ /assignments:(.*)/
			worker_name = $1
			version = SeapigDependency.versions('Task:assigned:'+worker_name)
			data = {
				tasks: Task.where("tasks.id in (SELECT task_statuses.task_id FROM  task_statuses WHERE task_statuses.current  AND task_statuses.status = 'assigned' AND task_statuses.created_at > ? AND task_statuses.worker_id = (select id from workers where name = ?))", Time.new - 10, worker_name).order('tasks.id').map { |task|
					task.description.merge(id: task.id, execution_id: task.execution_id, requirements: task.requirement.description, resources: task.status.resources.map { |resource| resource.remote_id }  )
				}
			}
			[data, version]
		}

	end

end
