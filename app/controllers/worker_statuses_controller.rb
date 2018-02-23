class WorkerStatusesController < ApplicationController

	skip_before_filter :verify_authenticity_token, only: :create

	def create
		Worker.transaction {
			worker = Worker.find(params[:id])
			worker.status.update(current: false)
			WorkerStatus.create!(worker_id: worker.id, current: true, data: params[:status])
			SeapigDependency.bump('Worker')
			render json: worker
		}
	end

end
