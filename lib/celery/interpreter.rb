#!/bin/ruby
# coding: utf-8
require 'rcelery'
require './lib/common.rb'
require 'rest_client'
require "open3"
require "awesome_print"
require 'json'
require 'amqp'
require "./lib/task_constructor.rb"

# "Fixes expiry token on task result."		
RCelery::Task.result_queue_expires = 1

def handleTaskResult(workitem)
	puts "Connected to AMQP broker. Running #{AMQP::VERSION} version of the gem..."
	puts "Getting a new channel."	
	channel  = RCelery.get_new_channel
	puts "Binding to default exchange."	
	exchange = channel.direct("", :durable => true, :mandatory => false)
	#channel.queue("bureaucrat_msgs",:durable => true).bind(exchange,:routing_key => 'bureaucrat_msgs')
	puts "Publishing workitem with bureaucrat_msgs key."		
	exchange.publish(JSON.dump(workitem),:routing_key => 'bureaucrat_msgs', :delivery_mode => 2, :content_type => 'application/x-bureaucrat-message')
	
end


module Testing
	include RCelery::TaskSupport	
	task(ignore_result: false)
	def jfdi(workitem)
		puts 'Interpreter online.'
		tasks = TaskProcedure.create_tasks(workitem).compact
		return workitem if not tasks
		puts "Defining execution."
		tags = {package: [workitem["payload"]["package"].to_s], project: [workitem["payload"]["project"].to_s]}
		if workitem["payload"]["pr"] and workitem["payload"]["pr"]["url"] then tags[:gerrit] = workitem["payload"]["pr"]["url"] end
		if workitem["payload"]["pr"] and workitem["payload"]["pr"]["username"] then tags[:author] = workitem["payload"]["pr"]["username"] end		
		execution = {execution: {tasks: tasks, creator: "CI", tags: tags }}
		ap execution
		result = nil
		Open3.popen3("bundle exec ruby ./lib/celery/client.rb") {|i, o, e, t|
			i.write(JSON.dump(execution))
			i.close
			x = o.read
			result = JSON.parse(x)
			execution_id = result["id"]
			results = result["tasks"].map { |task|
				task["artifacts"].map { |artifact|
					puts "All artifacts are parsed, but only test_result is uploaded."		
					if artifact["name"] == "test_result"
						end_result = RestClient.get(SCHEDULER_URI+'/artifacts/'+artifact["id"].to_s+'/'+artifact["name"].to_s)
					else
						next
					end
				}

				
			}
			t = results.flatten.compact.map { |e| e.to_f }
			t2 = (t.inject(0){ |sum, el| sum + el }.to_f / t.size).to_f
			(t2 > 0) ? result = 0 : result = -1
			
			execution_uri = SCHEDULER_URI+'/a?show=executions&execution_id='+execution_id.to_s
			
			workitem["payload"].merge!(results:[{"vote": result,"reported": false,"type":"Testing","desc":workitem["payload"]["package"].to_s+" robot tests: "+t2.to_s+" % of tests passed. URL of test execution is: "+execution_uri}])
			handleTaskResult(workitem)
		}
#		results = execute_tasks.delay(end_result)				
	rescue Exception => e
		p e
		p e.backtrace
	end

	
end     
 

