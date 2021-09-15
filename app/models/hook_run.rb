class HookRun < ApplicationRecord

	has_many :artifacts
	has_one :task_hook
	has_one :execution_hook
	belongs_to :task, optional: true
	belongs_to :execution, optional: true


	def self.run_hook(hook_name, entity_type, entity_state, entity_id, hook_args, hook_stdin)
		hooks_dir = 'project/hooks'
		hooks = Dir.glob("#{hooks_dir}/*")
		raise "Hook name should not contain '/'!"  if hook_name.include?("/")
		raise "Hook doesn't exist!"  if !hooks.any? {|h| File.basename(h) == hook_name }
		hook_path = "./" + hook_name
		Bundler.with_clean_env {
			time_started = Time.now
			hook_output, hook_error, hook_status = Open3.capture3([hook_path, hook_path], *hook_args, stdin_data: hook_stdin, chdir: hooks_dir)
			time_finished = Time.now
			hook_run = HookRun.create(name: hook_name, entity_type: entity_type, entity_state: entity_state, arguments: hook_args, exit_code: hook_status.exitstatus, created_at: time_started, finished_at: time_finished)
			case entity_type
			when "execution instance"
				hook_run.execution_id = entity_id
			when "task instance"
				hook_run.task_id = entity_id
				hook_run.execution_id = hook_run.task.execution_id
			end
			hook_run.save!
			Artifact.create!(data: hook_error, mimetype: "text/plain", filename: "stderr", hook_run: hook_run)
			Artifact.create!(data: hook_output, mimetype: "text/plain", filename: "stdout", hook_run: hook_run)
			Artifact.create!(data: hook_stdin, mimetype: "text/plain", filename: "stdin", hook_run: hook_run)
			return hook_run
		}
	end
end
