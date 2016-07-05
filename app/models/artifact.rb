class Artifact < ActiveRecord::Base

	belongs_to :task
	belongs_to :execution
end
