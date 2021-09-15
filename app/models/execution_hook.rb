class ExecutionHook < ActiveRecord::Base
	belongs_to :hook_run, optional: true
end
