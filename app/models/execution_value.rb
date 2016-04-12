class ExecutionValue < ActiveRecord::Base

	acts_as_seapig_dependency

	belongs_to :execution
	belongs_to :value
	
end
