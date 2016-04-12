class WorkerStatus < ActiveRecord::Base

	acts_as_seapig_dependency

	belongs_to :worker
	scope :current, ->{ where(:current) }

end
