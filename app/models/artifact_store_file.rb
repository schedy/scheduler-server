class ArtifactStoreFile < ArtifactStore

	def self.directory(artifact)
		if artifact.execution_id
			"public/storage/artifacts/"+artifact.created_at.strftime("%Y-%m-%d")+"/"+artifact.execution_id.to_s+"-"
		else
			"public/storage/artifacts/"+artifact.created_at.strftime("%Y-%m-%d")+"/"+artifact.task.execution_id.to_s+"/"+artifact.task_id.to_s
		end
	end

	def self.name(artifact)
		artifact.id.to_s+"_"+artifact.name.gsub(/[^a-zA-Z0-9\-\.]/,"_")
	end


	def self.put(artifact, data)
		FileUtils.mkdir_p(directory(artifact))
		case (artifact.storage_handler_data or {})["compressor"]
		when 'lz4'
			open("|lz4 -z - "+directory(artifact)+"/"+name(artifact)+".lz4 2>/dev/null", "w", encoding: 'ascii-8bit') { |file| file.write(data) }
		when nil
			open(directory(artifact)+"/"+name(artifact), "w", encoding: 'ascii-8bit') { |file| file.write(data) }
		end
	end


	def self.get(artifact)
		case (artifact.storage_handler_data or {})["compressor"]
		when 'lz4'
			open("|lz4 -d -c "+directory(artifact)+"/"+name(artifact)+".lz4", encoding: 'ascii-8bit') { |file| file.read }
		when nil
			open(directory(artifact)+"/"+name(artifact), encoding: 'ascii-8bit') { |file| file.read }
		end
	end

end
