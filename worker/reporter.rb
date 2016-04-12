#!/bin/env ruby

require 'seapig-client'


require './config.rb'
require './database.rb'


last_report = 0
report = false

EM.run {
	
	Database.connect()
	seapig_server = SeapigServer.new(SEAPIG_URI, name: 'reporter-'+WORKER_NAME)
	status = seapig_server.master('worker-status-'+WORKER_NAME)


	EM.add_periodic_timer(1) {
		next if (not report) and (Time.new.to_f - last_report < 60)
		last_report = Time.new.to_f

		puts "%s - uploading status"%[Time.new.strftime('%Y-%m-%d %M:%H:%S')]
		
		resources = Database::Resource.all.to_a
		status['timestamp'] = last_report
		status['resources'] = resources.map { |resource|
			{
				id: resource.id,
				type: resource.description['type'],
				task_id: resource.task_id
			}
		}
		p status
		status.changed
		report = false
	}
	

	Thread.new {
		ActiveRecord::Base.connection_pool.with_connection { |connection|
			connection = connection.instance_variable_get(:@connection)
			connection.exec("LISTEN resources_change")
			loop {
				connection.wait_for_notify { |channel, pid, payload|
					report = true
				}
			}
		}
	}

}



