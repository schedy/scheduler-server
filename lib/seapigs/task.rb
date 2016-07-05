require './config/environment.rb'

class TaskSingle < Producer

	@patterns = [ 'task-*' ]


	def self.produce(object_id)
		object_id =~ /task-(\d+)/
		id = $1.to_i
		version = SeapigDependency.versions('Task','TaskStatus')
		task = Task.find(id)
		data = {
			id: task.id,
			description: task.description,
			artifacts: task.artifacts.map { |artifact|
				{
					id: artifact.id,
					name: artifact.name,
					mimetype: artifact.mimetype,
				}
			}
		}
		[data, version]
	end

end
