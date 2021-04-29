require './config/environment.rb'

class TaskSingle < Producer
	@patterns = [ 'task-*' ]

	def self.produce(seapig_object_id)
		seapig_object_id =~ /task-(\d+)/
		id = $1.to_i
		version = SeapigDependency.versions('Task')
		task = Task.find(id)
		data = {
			id: task.id,
			description: task.description,
			artifacts: task.artifacts.group_by { |artifact| artifact.name }.map { |_name, artifact_versions|
				artifact = artifact_versions.sort_by { |artifact| artifact.created_at }[-1]
				{
					id: artifact.id,
					name: artifact.name,
					mimetype: artifact.mimetype,
					size: artifact.size,
					external_url: artifact.external_url,
					views: ArtifactView.views(artifact)
				}
			},
			requirements: task.requirement.description
		}
		[data, version]
	rescue ActiveRecord::RecordNotFound
		[{}, version]
	end
end
