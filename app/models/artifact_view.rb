class ArtifactView
	def self.handles?(handle)
		@@handle == handle
	end

	def self.views(artifact)
		return [] if not artifact.data?
		ObjectSpace.each_object(Class).select { |klass| klass < ArtifactView }.map { |klass| klass.views(artifact) }.flatten.compact
	end

	def self.view(handle, artifact, path, context)
		ObjectSpace.each_object(Class).find { |klass| klass < ArtifactView and klass.handles?(handle) }.view(artifact, path, context)
	end
end

Dir[Rails.root.to_s+'/app/models/artifact_view_*.rb'].sort.each { |artifact_view| $stderr.puts 'Loading: '+artifact_view; require artifact_view }
Dir[Rails.root.to_s+'/project/models/artifact_view_*.rb'].sort.each { |artifact_view| require artifact_view }
