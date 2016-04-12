#!/bin/env ruby

require 'seapig-client'


require './config.rb'
require './manager.rb'
require './database.rb'




EM.run {
	
	Database.connect()
	seapig_server = SeapigServer.new(SEAPIG_URI, name: 'estimator-'+WORKER_NAME)
	estimates = seapig_server.master('estimates:'+WORKER_NAME)
	tasks_waiting = seapig_server.slave('tasks-waiting')
	reestimate = Proc.new {
		puts "-"*80
		resources = Database::Resource.free
		tasks_waiting['tasks'].each { |task|
			plan = Manager.estimate(resources, task['requirements'])
			if plan
				estimates[task['id'].to_s] = plan
				puts "%8i - %6.2f"%[task['id'],plan[:estimate]]
			else
				estimates.delete(task['id'].to_s)
			end
				
		}
		estimates.changed
	}
	tasks_waiting.onchange(&reestimate)

	Thread.new {
		ActiveRecord::Base.connection_pool.with_connection { |connection|
			connection = connection.instance_variable_get(:@connection)
			connection.exec("LISTEN resources_change")
			loop {
				connection.wait_for_notify { |channel, pid, payload|
					EM.schedule reestimate
				}
			}
		}
	}

}



