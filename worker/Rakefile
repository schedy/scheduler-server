require 'pg'
require 'active_record'
require 'yaml'

namespace :build do

	desc "Build scheduler worker tarball"
	task :tarball do
		sh 'unset RUBYOPT; bundle package --all'
		FileUtils.mkdir_p 'docker/build'
		FileUtils.rm 'docker/scheduler-worker.tar.bz2' if File.exists?('docker/scheduler-worker.tar.bz2')
		Dir.chdir 'docker/build'
		['reporter.rb', 'migrations', 'Rakefile', 'executors', 'lib', 'resources', 'Gemfile', 'Gemfile.lock', 'amhub_device_configuration.robot', 'LICENSE', 'cleaner.rb', 'config.rb', 'database.rb', 'estimator.rb', 'executor.rb','manager.rb'].each { |dir|
			FileUtils.cp_r '../../'+dir, '.'
		}
		puts `tar -jcvf ../scheduler-worker.tar.bz2 *`
		Dir.chdir '..'
		FileUtils.rm_r 'build'
		Dir.chdir '..'
	end


	desc "Build scheduler worker docker image"
	task docker: "tarball" do
		Dir.chdir 'docker'
		sh 'sudo docker build .'
		puts
		puts '***** Read docker/Dockerfile to find out how to start your newly created image *****'
		puts
	end


	
end


namespace :db do
	
	desc "Migrate the db"
	task :migrate do
		require './config.rb'
			ActiveRecord::Base.establish_connection(DATABASE)
			ActiveRecord::Migrator.migrate("migrations")
	end
	
end
