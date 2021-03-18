require 'shellwords'
require 'open3'

class ExecutionsController < ApplicationController

	skip_before_action :verify_authenticity_token, only: [:create, :duplicate]


	def create
		execution_description = nil
		summary = {}
		if not params[:hook].blank?
			hooks_dir = 'project/hooks'
			hook_name = params[:hook]+(params[:format] ? "." : "")+(params[:format] || "")
			hooks = Dir.glob("#{hooks_dir}/*")
			raise 'Incorrect hook request !' if (hook_name.include?("/") or !hooks.any? {|h| File.basename(h) == hook_name })
			hook = [hooks_dir,Shellwords.escape(hook_name)].join('/')
			Bundler.with_clean_env {
				hook_input = request.raw_post.force_encoding("UTF-8")
				raise "Hook input is not a valid UTF-8" if not hook_input.valid_encoding?
				hook_output, hook_error, hook_status = Open3.capture3(hook, :stdin_data=>hook_input)
				if hook_status.success? and (execution_description = JSON.load(hook_output))
					execution_description = JSON.load(hook_output)
					execution_description = execution_description["execution"]  if execution_description["execution"]
					summary["hook_message"] = hook_error
				else
					return render json: { error: "Execution creation failed", hook_exit_code: hook_status, hook_message: hook_error }, status: 422
				end
			}
		else
			execution_description = params[:execution].to_unsafe_h
		end

		execution = Execution.create_with_tasks(execution_description)
		summary["execution"] = Execution.detailed_summary(include: ["task","task_details","task_artifacts","artifacts","tags"], conditions: "executions.id = ?", params: [execution.id]).first.description
		render json: summary
	end


	def show
		execution = Execution.find(params[:id])
		summary = Execution.detailed_summary(include: ["task","task_details","task_artifacts","artifacts","tags","task_tags"], conditions: "executions.id = ?", params: [execution.id]).first.description
		respond_to { |format|
			format.json { render json: summary }
		}
	end


	def duplicate
		execution_id = params[:id]
		original_execution = Execution.find(execution_id)
		duplicate_execution = original_execution.duplicate_with_tasks
		render json: duplicate_execution
	end

end
