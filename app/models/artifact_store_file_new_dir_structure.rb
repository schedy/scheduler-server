class ArtifactStoreFileNewDirStructure < ArtifactStore

	def self.directory(artifact, volume)
		if artifact.execution_id
			Rails.root.to_s+"/public/storage/artifacts/"+volume+"/"+artifact.created_at.strftime("%Y-%m-%d")+"/execution-"+artifact.execution_id.to_s
		elsif artifact.task_id
			Rails.root.to_s+"/public/storage/artifacts/"+volume+"/"+artifact.created_at.strftime("%Y-%m-%d")+"/execution-"+artifact.task.execution_id.to_s+"/task-"+artifact.task_id.to_s
		elsif artifact.hook_run_id
			case artifact.hook_run.entity_type
			when "execution class"
				Rails.root.to_s+"/public/storage/artifacts/"+volume+"/"+artifact.created_at.strftime("%Y-%m-%d")+"/execution/hook-"+artifact.hook_run.entity_state+"-"+artifact.hook_run.id.to_s
			when "execution instance"
				Rails.root.to_s+"/public/storage/artifacts/"+volume+"/"+artifact.created_at.strftime("%Y-%m-%d")+"/execution-"+artifact.hook_run.execution_id.to_s+"/hook-"+artifact.hook_run.entity_state+"-"+artifact.hook_run.id.to_s
			when "task instance"
				Rails.root.to_s+"/public/storage/artifacts/"+volume+"/"+artifact.created_at.strftime("%Y-%m-%d")+"/execution-"+artifact.hook_run.task_hook.task.execution_id.to_s+"/task-"+artifact.hook_run.task_id.to_s+"/hook-"+artifact.hook_run.entity_state+"-"+artifact.hook_run.id.to_s
			else
				raise "Unsupported entity type: %p" %artifact.hook_run.entity_type
			end
		else
			raise "Artifact has to belong to either an execution or a task or a hook run!"
		end
	end

	def self.name(artifact)
		artifact.id.to_s+"_"+artifact.name.gsub(/[^a-zA-Z0-9\-\.]/,"_")
	end


	def self.put(artifact, data)
		FileUtils.mkdir_p(directory(artifact, "current"))
		case (artifact.storage_handler_data or {})["compressor"]
		when 'lz4'
			open("|lz4 -f -z - "+directory(artifact, "current")+"/"+name(artifact)+".lz4 2>/dev/null", "w", encoding: 'ascii-8bit') { |file| file.write(data) }
		when nil
			open(directory(artifact, "current")+"/"+name(artifact), "w", encoding: 'ascii-8bit') { |file| file.write(data) }
		end
	end


	def self.locate_file(artifact, basename)
		path = directory(artifact, "current")+"/"+basename
		return path if File.file?(path)
		Dir[Rails.root.to_s+"/public/storage/artifacts/*"].select { |volume| Dir.exist?(volume) and not File.basename(volume) == 'current' }.sort.each { |volume|
			path = directory(artifact, File.basename(volume))+"/"+basename
			return path if File.file?(path)
		}
		raise "File not found: %s"%[basename]
	end


	def self.get(artifact)
		case (artifact.storage_handler_data or {})["compressor"]
		when 'lz4'
			open("|lz4 -d -c "+locate_file(artifact, name(artifact)+".lz4"), encoding: 'ascii-8bit') { |file| file.read }
		when nil
			open(locate_file(artifact, name(artifact)), encoding: 'ascii-8bit') { |file| file.read }
		end
	end

end
