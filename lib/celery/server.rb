Dir.chdir('../..') if not File.exists?('config/environment.rb')  #fuck rcelery

require './config/environment.rb'
require 'rcelery'
require 'pp'
require 'yaml'
require 'rest_client'

Execution; ExecutionStatus; Task; TaskStatus  #tickling rails autoloader

#RCelery::Task.result_queue_expires = 1

module Testing
	include RCelery::TaskSupport	
	task(ignore_result: false)
	def execute_tasks(args)
		p :args, args, :argsend
		connection = Execution.connection
		puts "-"*80 + " new execution"
		p Execution
		execution = Execution.create_with_tasks(args["execution"])
		pp Execution.detailed_summary(include: ["task_details"], conditions: "e.id = ?", params: [execution.id]).first.description
		connection = connection.instance_variable_get(:@connection)
		puts "Listen changes on bound seapig objects."				
		connection.exec("LISTEN seapig_dependency_changed")
		Execution.uncached {
			loop {				
				status = nil
				connection.wait_for_notify { |channel, pid, payloads|
					exec = Execution.find(execution.id)
					status = exec.status.status
					puts Time.new.strftime('%Y-%m-%d %H:%M:%S') + " " + status 
				}
				break if status == "finished"
			}
		}
		ActiveRecord::Base.clear_active_connections!
		execution = Execution.find(execution.id)
		summary = Execution.detailed_summary(include: ["task_details","artifacts"], conditions: "e.id = ?", params: [execution.id]).first.description
		pp summary
		summary
	rescue Exception => e
		p e
		pp e.backtrace
	end
end     
