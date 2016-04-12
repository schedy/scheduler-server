class TaskStatus < ActiveRecord::Base

	belongs_to :task
	acts_as_seapig_dependency

	scope :current, ->{ where(:current) }
	
end
