namespace :build do

	desc "Build scheduler server tarball"
	task tarball: "assets:precompile" do
		sh 'unset RUBYOPT; bundle package --all'
		FileUtils.mkdir_p 'deploy/build'
		FileUtils.rm 'deploy/scheduler-server.tar.bz2' if File.exists?('deploy/scheduler-server.tar.bz2')
		Dir.chdir 'deploy/build'
		['app', 'bin', 'config', 'db', 'lib', 'public', 'vendor', 'Gemfile', 'Gemfile.lock', 'LICENSE', 'README.rdoc', 'Rakefile', 'config.ru'].each { |dir|
			FileUtils.cp_r '../../'+dir, '.'
		}
		FileUtils.rm_r 'app/assets'
		puts `tar -jcvf ../scheduler-server.tar.bz2 *`
		Dir.chdir '..'
		FileUtils.rm_r 'build'
		Dir.chdir '..'
	end
end
