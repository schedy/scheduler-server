class TaskHook < ApplicationRecord
	belongs_to :hook_run, optional: true
end
