class ArtifactsController < ApplicationController

	skip_before_action :verify_authenticity_token, only: :create

	def create
		artifact = if params[:task_id]
			Artifact.create(task: Task.find(params[:task_id]), data: params[:data])
		elsif params[:execution_id]
			Artifact.create(execution: Execution.find(params[:execution_id]), data: params[:data])
		end
		render json: { id: artifact.id }
	end


	def show
		artifact = if params[:task_id]
			Task.find(params[:task_id]).artifacts.where(name: params[:path].split('/')[0]).order("created_at DESC").first
		elsif params[:execution_id]
			Execution.find(params[:execution_id]).artifacts.where(name: params[:path].split('/')[0]).order("created_at DESC").first
		end
		artifact.send_data(self, params["path"].split("/",2)[1])
	end

end
