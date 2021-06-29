require './config/environment.rb'

class ExecutionSingle < Producer

	@patterns = [ 'execution:*' ]


	def self.produce(seapig_object_id)
		seapig_object_id =~ /execution:(\d+)/
		id = $1.to_i
		version = SeapigDependency.versions('Execution:%010i'%[id])
		data = Execution.detailed_summary(include: ["task_tag_stats","task_statuses","hooks","tags"], conditions: "executions.id = ?", params: [id]).first
		return [ {}, version ] if not data
		artifact_data = {
			artifacts: Execution.find(id).artifacts.group_by { |artifact| artifact.name }.map { |name, artifact_versions|
				artifact = artifact_versions.sort_by { |artifact| artifact.created_at }[-1]
				{
					id: artifact.id,
					name: artifact.name,
					mimetype: artifact.mimetype,
					size: artifact.size,
					external_url: artifact.external_url,
					views: ArtifactView.views(artifact)
				}
			}
		}
		data = data.description.merge artifact_data
		[data, version]
	end

end
