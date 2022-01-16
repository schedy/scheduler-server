class ExecutionStatus < ActiveRecord::Base
	belongs_to :execution
	scope :current, ->{ where(:current) }
	
end
