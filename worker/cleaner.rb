#!/bin/env ruby
# coding: utf-8

require 'fileutils'
require 'json'
require 'daemons'
require 'seapig-client'
require 'rest-client'

require './config.rb'
require './manager.rb'
require './database.rb'
require 'active_support/core_ext/hash'

#TODO: Greener cleaner, less polling, more triggers.

EM.run {
	Database.connect()
	tasks_directory = Dir.pwd.to_s+"/tasks/"
	statuses = ['waiting','preparing','transitioning','starting','finished','crashed']
	EM.add_periodic_timer(3){
		puts 'Cleaner triggered.'
		#### Periodicly check if process is alive.
		Database::Task.where('pid IS NOT NULL AND cleaned_at IS NULL').map { |task|
			begin
				puts "Checking "+task.id.to_s
				###Process is alive.
				task_id = task.id
				pid = Process.getpgid(task.pid.to_i);				
			rescue Errno::ESRCH
				###Process is dead.
				puts "This task's process looks dead: "+task.id.to_s
				##Check if process left finished file in its dir.
				##This file is subject to change, and MUST change.
				task_report_html = tasks_directory+task_id.to_s+"/report.html"	
				task_report = tasks_directory+task_id.to_s+"/output.xml"

				if File.file?(task_report_html)  
 					task_output_xml = File.read(task_report)
					puts "Freeing resources bind to: "+task.id.to_s
					#Free its resources.
					Database::Resource.free_resource(task_id)
					
					puts "Uploading results: "+task.id.to_s
					puts "Uploading parsed results: "+task.id.to_s
					
					parsed_result = Hash.from_xml(task_output_xml)["robot"]["suite"]["status"]["status"]
					parsed_name = Hash.from_xml(task_output_xml)["robot"]["suite"]["suite"]["test"]["name"]				
					robot_test_result = File.open(tasks_directory+task_id.to_s+"/test_result", "w+") { |file| file.write(parsed_result == "PASS" ? "100" : "0" )}
					puts "Result is: "+parsed_result.to_s	
					RestClient.post(SCHEDULER_URI+'/artifacts', task: task_id, data: File.new(tasks_directory+task_id.to_s+"/test_result") )
					
					RestClient.post(SCHEDULER_URI+'/task_values',task_id: task_id, property: "result", value: parsed_result)
					RestClient.post(SCHEDULER_URI+'/task_values',task_id: task_id, property: "name", value: parsed_name )					

					
					RestClient.post(SCHEDULER_URI+'/artifacts', task: task_id, data: File.new(task_report))
					#Inform server that task has finished.
					puts "Setting it to finished: "+task.id.to_s			
					RestClient.post(SCHEDULER_URI+'/task_statuses', task_id: task_id, status: "finished")					

				##If process did not leave a finished file.
				else					
					#Inform server that task has FAILED after transition is done.
					if statuses.index(task.status.to_s).to_i > 2
						puts "This task has failed: "+task.id.to_s		
						Database::Resource.free_resource(task_id)						
						RestClient.post(SCHEDULER_URI+'/task_statuses', task_id: task_id, status: "failed")
					else		
						#Inform server that task has CRASHED before or during tranisiton.
						puts "This task has crashed: "+task.id.to_s	
						RestClient.post(SCHEDULER_URI+'/task_statuses', task_id: task_id, status: "crashed")
					end

				end
				begin
					puts "Marking task as cleaned: "+task.id.to_s
					Process.kill('QUIT', task.pid.to_i)
					puts 'Child of executor is killed.'
				rescue Errno::ESRCH
					puts 'Fool, you cannot kill what does not bleed !'
				end
				
				task.update(cleaned_at: Time.now())
				
				
			else
				puts "Task ID :"+task.id.to_s+" is alive with pid "+task.pid.to_s
				
			end						
		}
		
	}

}
