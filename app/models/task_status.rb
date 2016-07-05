class TaskStatus < ActiveRecord::Base

	belongs_to :task
	scope :current, ->{ where(:current) }
	
end
