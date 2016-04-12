class TaskValue < ActiveRecord::Base

	acts_as_seapig_dependency


	belongs_to :task
	belongs_to :value

end
