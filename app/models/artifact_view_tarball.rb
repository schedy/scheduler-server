class ArtifactViewTarball < ArtifactView

	@@handle = 'tarball'

	def self.handles?(handle)
		@@handle == handle
	end


	def self.views(artifact)
		[{path: @@handle+'/index.html', label: 'index.html'}] if artifact.name =~ /.*\.tar.bz2$/
	end


	def self.view(artifact, path, context)
		dirname = 'public/storage/cache/artifacts/%s/%09i/'%[artifact.created_at.strftime('%Y%m%d'),artifact.id]
		filename = dirname+'/'+path
		if not Dir.exist?(dirname)
			FileUtils.mkdir_p(dirname)
			open("| tar jxvC '#{dirname}'",'w') { |tar| tar.write(artifact.data.force_encoding('UTF-8')) }
		end
		context.send_file filename, type: MIME::Types.type_for(filename).first, disposition: 'inline'
	end

end
