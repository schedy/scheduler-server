class ExecutionStatus < ActiveRecord::Base

	acts_as_seapig_dependency

	belongs_to :execution
	scope :current, ->{ where(:current) }
	
end
