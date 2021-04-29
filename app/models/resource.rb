class Resource < ActiveRecord::Base

	has_one :status, ->{ where current: true}, class_name: 'ResourceStatus'
	has_and_belongs_to_many :task_statuses
	belongs_to :worker

end
