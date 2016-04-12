class Value < ActiveRecord::Base

	belongs_to :property
	has_many :task_values

end
