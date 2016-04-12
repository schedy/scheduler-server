
namespace :build do

	desc "Build scheduler server tarball"
	task tarball: "assets:precompile" do
		sh 'unset RUBYOPT; bundle package --all'
		FileUtils.mkdir_p 'docker/build'
		FileUtils.rm 'docker/scheduler-server.tar.bz2' if File.exists?('docker/scheduler-server.tar.bz2')
		Dir.chdir 'docker/build'
		['app', 'bin', 'config', 'db', 'lib', 'public',	'vendor', 'Gemfile', 'Gemfile.lock', 'LICENSE', 'README.rdoc', 'Rakefile', 'config.ru', 'config.rb'].each { |dir|
			FileUtils.cp_r '../../'+dir, '.'
		}
		FileUtils.rm_r 'app/assets'
		puts `tar -jcvf ../scheduler-server.tar.bz2 *`
		Dir.chdir '..'
		FileUtils.rm_r 'build'
		Dir.chdir '..'
	end


	desc "Build scheduler server docker image"
	task docker: "tarball" do
		Dir.chdir 'docker'
		sh 'sudo docker build .'
		puts
		puts '***** Read docker/Dockerfile to find out how to start your newly created image *****'
		puts
	end

end
