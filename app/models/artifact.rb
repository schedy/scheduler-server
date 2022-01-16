class Artifact < ActiveRecord::Base
	belongs_to :task, optional: true
	belongs_to :execution, optional: true
	belongs_to :hook_run, optional: true


	def self.create!(task: nil, execution: nil, data:, mimetype:, filename:, hook_run: nil)
		raise "Artifact has to belong to some task or execution or hook run!" if (not task) and (not execution) and (not hook_run)
		artifact = Artifact.new
		artifact.task = task
		artifact.execution = execution
		artifact.hook_run = hook_run
		artifact.mimetype = mimetype
		artifact.name = filename
		artifact.size = data.bytesize
		artifact.storage_handler = "ArtifactStoreFileNewDirStructure"
		artifact.storage_handler_data = { "compressor"=>"lz4" }
		artifact.created_at = Time.new
		artifact.save!
		ArtifactStoreFileNewDirStructure.put(artifact, data)
		SeapigDependency.bump('Execution:%010i'%[artifact.execution.id]) if execution #THINK: what about bumping task?
		artifact
	end

	def send_data(context, path)
		if (not path) or path.count('/') == 0
			context.send_data self.data, type: mimetype, disposition: 'inline'
		else
			handle, subpath = path.split('/', 2)
			ArtifactView.view(handle, self, subpath, context)
		end
	end

	def data
		ArtifactStore.store(self.storage_handler).get(self)
	end

	def data?
		return false if not self.storage_handler
		ArtifactStore.store(self.storage_handler).respond_to?(:get)
	end
end
