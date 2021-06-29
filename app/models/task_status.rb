class TaskStatus < ActiveRecord::Base

	self.primary_key = 'id'
	belongs_to :task
	has_and_belongs_to_many :resources
	scope :current, ->{ where(:current) }

end
