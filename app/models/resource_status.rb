class ResourceStatus < ActiveRecord::Base
	belongs_to :resource
	belongs_to :task, optional: true
end
