class Resource < ActiveRecord::Base

	has_one :status, ->{ where current: true}, class_name: "ResourceStatus"

end
