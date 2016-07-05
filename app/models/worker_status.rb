class WorkerStatus < ActiveRecord::Base

	belongs_to :worker
	scope :current, ->{ where(:current) }

end
