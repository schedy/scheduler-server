class Task < ActiveRecord::Base

	acts_as_seapig_dependency

	belongs_to :execution
	has_many :task_statuses
	has_one :status, ->{ where current: true }, class_name: "TaskStatus"
	has_many :artifacts
	has_many :task_values
	
end
