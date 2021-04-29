class TaskValue < ActiveRecord::Base
	belongs_to :task
	belongs_to :value
end
