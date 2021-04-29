class Artifact < ActiveRecord::Base
	belongs_to :task, optional: true
	belongs_to :execution, optional: true

	def self.create(task: nil, execution: nil, data:)
		raise 'Artifact has to belong to some task or execution.' if (not task) and (not execution)
		artifact = Artifact.new
		artifact.task = task
		artifact.execution = execution
		artifact.mimetype = data.content_type
		artifact.name = data.original_filename
		content = data.tempfile.read
		artifact.size = content.bytesize
		artifact.storage_handler = 'ArtifactStoreFile'
		artifact.storage_handler_data = { 'compressor'=>'lz4' }
		artifact.created_at = Time.new
		artifact.save!
		ArtifactStoreFile.put(artifact, content)
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
