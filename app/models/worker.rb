class Worker < ActiveRecord::Base

	has_many :worker_statuses
	has_one :status, ->{ where current: true }, class_name: 'WorkerStatus'
	has_many :resources
	
end
