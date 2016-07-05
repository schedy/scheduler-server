class Task < ActiveRecord::Base

	belongs_to :execution
	has_many :task_statuses
	has_one :status, ->{ where current: true }, class_name: "TaskStatus"
	has_many :artifacts
	has_many :task_values
	
end
