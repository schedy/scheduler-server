class TaskStatusesController < ApplicationController

	skip_before_filter :verify_authenticity_token, only: :create

	def create
		Task.transaction {
			task = Task.find(params[:task_id])
			task.status.update(current: false)
			TaskStatus.create!(task_id: task.id, current: true, status: params[:status])
			task.execution.update_status
			SeapigDependency.bump('TaskStatus')
			render json: task
		}
	end
end
