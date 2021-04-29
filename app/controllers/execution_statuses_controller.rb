require 'shellwords'

class ExecutionStatusesController < ApplicationController
	skip_before_action :verify_authenticity_token, only: [:create]

	def create
		execution_id = params[:execution_id]
		execution = Execution.find(execution_id)
		options = params[:options]
		target_tasks=nil
		execution.with_lock {
			target_tasks = execution.tasks.select { |task| task.status.status == options[:from] }
			target_tasks.map { |task|
				task.status.update(current: false)
				TaskStatus.create!({ task_id: task.id, current: true, status: options[:to] })
			}
			SeapigDependency.bump('Task', format('Execution:%010i', execution_id.to_i))
			SeapigDependency.bump('Task:waiting') if target_tasks.size.positive?
			Execution.find(execution_id).update_status(true)
		}
		render json: target_tasks
	end
end
