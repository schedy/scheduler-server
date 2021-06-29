class ArtifactViewConsole < ArtifactView

	@@handle = "console"

	def self.handles?(handle)
		@@handle == handle
	end


	def self.views(artifact)
		[{path: @@handle+'/console.html', label: "console"}]  if artifact.name =~ /(output|.log|.txt)$/
	end


	def self.view(artifact, path, context)
		dirname = 'public/storage/cache/artifacts/%s/%09i/'%[artifact.created_at.strftime("%Y%m%d"),artifact.id]
		filename = dirname+'/console.html'
		if not Dir.exist?(dirname)
			FileUtils.mkdir_p(dirname)
			open("| aha >'#{filename}'","w") { |aha|
				aha.write(artifact.data.force_encoding("UTF-8"))
			}
		end
		context.send_file filename, type: MIME::Types.type_for(filename).first, disposition: 'inline'
	end

end
