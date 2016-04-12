class ExecutionsController < ApplicationController

	skip_before_filter :verify_authenticity_token, only: :create
	
	def create
		execution = Execution.create_with_tasks(params[:execution])
		summary = Execution.detailed_summary(include: ["task_details","artifacts"], conditions: "e.id = ?", params: [execution.id]).first.description
		respond_to { |format|
			format.json { render json: summary }
		}
	end


	def show
		execution = Execution.find(params[:id])
		summary = Execution.detailed_summary(include: ["task_details","artifacts"], conditions: "e.id = ?", params: [execution.id]).first.description
		respond_to { |format|
			format.json { render json: summary }
		}
	end
end
