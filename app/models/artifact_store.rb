class ArtifactStore

	def self.store(name)
		Object.const_get(name)
	end

	def put(artifact, data)
		raise self.class.name + '::put is not implemented'
	end

end


Dir[Rails.root.to_s+'/app/models/artifact_store_*.rb'].each { |artifact_store| $stderr.puts 'Loading: '+artifact_store; require artifact_store }
Dir[Rails.root.to_s+'/project/models/artifact_store_*.rb'].each { |artifact_store| require artifact_store }
