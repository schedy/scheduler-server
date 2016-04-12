class Worker < ActiveRecord::Base

	acts_as_seapig_dependency

	has_many :worker_statuses
	has_one :status, ->{ where current: true }, class_name: "WorkerStatus"

end
