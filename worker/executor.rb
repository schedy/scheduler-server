#!/bin/env ruby
  
require 'jsonclient'
require 'fileutils'
require 'json'
require 'daemons'
require 'seapig-client'

require './config.rb'
require './manager.rb'
require './database.rb'


puts 'Executor online.'
EM.run {
	if Database.connect() then puts 'Successfully connected to database' end
	seapig_server = SeapigServer.new(SEAPIG_URI)
	scheduler_server = JSONClient.new

	assignments = seapig_server.slave('assignments:'+WORKER_NAME)
	puts assignments
	assignments.onchange { 
 		puts "Executing new assignments."
		assignments.each_pair { |task_id, task|			
			next if not Database::Task.where(id: task_id).blank?			
			scheduler_server.post(SCHEDULER_URI+'/task_statuses', task_id: task_id, status: "assigned")			
			#create Task in local db, with status 'pre-fork' or something		
			new_task = Database::Task.create!(id: task_id, status: "preparing")
			#perform estimate			
			plan = Manager.estimate(Database::Resource.free, task['requirements'])

			#upload task status 'waiting' if plan can't be done , and "next"
			if plan == nil
				scheduler_server.post(SCHEDULER_URI+'/task_statuses', task_id: task_id, status: "waiting")
				new_task.destroy!
			else
				#lock actors for that task
				#an example plan {:estimate=>0, :actors=>{"SUT"=>{:id=>1, :type=>"Device", :image=>"a", :count=>1, :tasks=>0},}, :steps=>[]}
				
				p task_id
				p Database::Task.all.to_a
				
				Database::Resource.lock(task_id,plan[:actors])
			
				#create task dir: tasks/TASK_ID
				task_directory = Dir.pwd.to_s+"/tasks/"+task_id.to_s
				dister_directory = Dir.pwd.to_s
				FileUtils::mkdir_p task_directory
				Database.disconnect()
				#consider https://github.com/rtomayko/posix-spawn			
				child_pid = fork do
					#task1 = Daemonize.call_as_daemon(Proc.new do
					seapig_server.detach_fd
					EM.stop_event_loop
					EM.release_machine
					Daemons.daemonize(app_name: 'executor', log_output: true, log_dir: task_directory)				
					child_pid = Process.pid
					Database.connect()
					Database::Task.find(task_id).update(pid: child_pid)					
					Dir.chdir(task_directory) 

					


					Database::Task.find(task_id).update(status: "transitioning")	
					scheduler_server.post(SCHEDULER_URI+'/task_statuses', task_id: task_id, status: "transition")

					transition = Manager.transition(plan[:steps])

					Database::Task.find(task_id).update(status: "started")	
					scheduler_server.post(SCHEDULER_URI+'/task_statuses', task_id: task_id, status: "started")
									
					File.open("task.json","w") do |f|
						f.write(task.merge(actors: plan[:actors]).to_json)
					end
					if not task["executor"].nil?
						execute_order = [dister_directory+"/executors/"+task['executor'].to_s].join(' ')
						p execute_order
						p 'Execution order received. This is not a drill.'
						exec execute_order
						p "Well done."
					else
						p "Could not find an executor."
					end
				end
				Process.detach(child_pid)
				Database.connect()
			end

		}
		sleep 1
	}
}


