class ArtifactViewSyslog < ArtifactView
	@@handle = 'syslog'

	def self.handles?(handle)
		@@handle == handle
	end

	def self.views(artifact)
		[{ path: @@handle+'/annotated.html', label: 'annotated' }] if artifact.name =~ /^syslog.*$/
	end

	def self.view(artifact, _path, context)
		dirname = 'public/storage/cache/artifacts/%s/%09i/'%[artifact.created_at.strftime('%Y%m%d'), artifact.id]
		filename = dirname+'/annotated.html'
		if not Dir.exist?(dirname)
			FileUtils.mkdir_p(dirname)
			open("| bundle exec ruby lib/annotator/syslog-to-html.rb lib/annotator/syslog.rb 'Task##{artifact.task.id} Artifact##{artifact.id} #{artifact.name}' >'#{filename}'", 'w') { |annotator|
				annotator.write(artifact.data.force_encoding('UTF-8'))
			}
		end
		context.send_file filename, type: MIME::Types.type_for(filename).first, disposition: 'inline'
	end
end
