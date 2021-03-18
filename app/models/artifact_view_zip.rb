class ArtifactViewZip < ArtifactView

	@@handle = "zip"


	def self.handles?(handle)
		@@handle == handle
	end


	def self.views(artifact)
		[{ path: @@handle + "/index.html", label: "index.html" }] if artifact.name =~ /.*\.zip$/
	end


	def self.view(artifact, path, context)
		dirname = "public/storage/cache/artifacts/%s/%09i/"%[artifact.created_at.strftime("%Y%m%d"), artifact.id]
		filename = dirname + "/" + path
		if not Dir.exist?(dirname)
			FileUtils.mkdir_p(dirname)
			open(tmp_file_name = dirname + "_.zip", "w") { |file| file.write(artifact.data.force_encoding("UTF-8")) }
			`unzip -d '#{dirname}' '#{tmp_file_name}'`
			FileUtils.rm(tmp_file_name)
		end
		context.send_file(filename, type: (MIME::Types.type_for(filename).first || 'text/plain'), disposition: "inline")
	end

end
