class ResourceController < ApplicationController

	skip_before_action  :verify_authenticity_token, only: :index

	def index
		Resource.all
		ResourceStatus.transaction {
			resource_statuses = params[:statuses]
			resource_statuses.each { |worker_name, resources|
				worker = Worker.find_or_create_by(name: worker_name)
				resources.each { |resource_id, description|
					resource = Resource.find_or_create_by(worker_id: worker.id, remote_id: resource_id)
					resource_status = ResourceStatus.new
					resource_status.task_id = description[:task_id]
					resource_status.description = description
					resource_status.resource_id = resource.id
					ResourceStatus.where(resource_id: resource.id, current: true).update_all(current: false)
					resource_status.current = true
					resource_status.save!
				}
			}
			render json: resource_statuses.to_json
		}
	end

end
