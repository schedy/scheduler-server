require 'json'

class ExecutionsController < ApplicationController

	skip_before_action :verify_authenticity_token, only: [:create, :create_with_hook, :retrigger, :append_tasks]


	def create_with_hook
		hook_name = params[:hook]+(params[:format] ? "." : "")+(params[:format] || "")
		hook_input = request.raw_post.force_encoding("UTF-8")
		raise "Hook input is not a valid UTF-8" if not hook_input.valid_encoding?
		summary = Execution.create_execution_with_hook(hook_name, hook_input)
		render json: summary
	rescue ExecutionCreationError => e
		hook_error = e.hook_run.artifacts.find_by(name: "stderr").data
		hook_exit_code = e.hook_run.exit_code
		hook_run_id = e.hook_run.id
		render json: { error: e.message, hook_error: hook_error, hook_exit_code: hook_exit_code, hook_run_id: hook_run_id} , status: 422
	end

	def create
		execution_description = params[:execution].to_unsafe_h
		summary = Execution.create_execution_with_description(execution_description)
		render json: summary
	end

	def append_tasks
		execution = Execution.find(params[:id])
		task_descriptions = params.to_unsafe_h[:tasks]
		execution.append_tasks(task_descriptions)
		summary = {}
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


	def retrigger
		hook = ExecutionHook.find_by(execution_id: params[:id], status: "initiating")
		if hook != nil
			hook_input = hook.hook_run.artifacts.find_by(name: "stdin").data
			summary = Execution.create_execution_with_hook(hook.hook, hook_input)
		else
			exec = Artifact.find_by(execution_id: params[:id], name: "execution.json").data
			execution_description = JSON.load(exec)
			summary = Execution.create_execution_with_description(execution_description)
		end
		render json: summary
	rescue ExecutionCreationError => e
		return render json: e.error_json , status: 422
	end

end
