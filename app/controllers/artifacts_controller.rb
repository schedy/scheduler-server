class ArtifactsController < ApplicationController

	skip_before_filter :verify_authenticity_token, only: :create

	def create
		artifact = Artifact.new
    if params[:task]
		  artifact.task = Task.find(params[:task])
    elsif params[:execution]
		  artifact.execution = Execution.find(params[:execution])
    end
		artifact.mimetype = params[:data].content_type
		artifact.name = params[:data].original_filename
		artifact.data = params[:data].tempfile.read
		artifact.save!

		render json: { id: artifact.id }
	end


	def show
		artifact = Artifact.find(params[:id])
		send_data artifact.data, type: artifact.mimetype, disposition: 'inline'
	end
end
