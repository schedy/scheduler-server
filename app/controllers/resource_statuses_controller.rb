class ResourceStatusesController < ApplicationController

	skip_before_filter  :verify_authenticity_token, only: :create

	def create
		ResourceStatus.transaction {
			resource_statuses = params[:statuses]
			resource_statuses.each { |worker_name, resources|
				worker = Worker.find_or_create_by(name: worker_name)
				resources.each { |description|
					worker.with_lock {
						resource = Resource.find_or_create_by(worker_id: worker.id, remote_id: description["id"])
						resource_status = ResourceStatus.new
						resource_status.task_id = description[:task_id]
						resource_status.role = description[:role]
						resource_status.description = description[:description]
						resource_status.resource_id = resource.id
						resource_status.created_at = description[:created_at]
						ResourceStatus.where(resource_id: resource.id, current: true).update_all(current: false)
						resource_status.current = true
						resource_status.save!(touch: false)
					}
				}
			}
			render json: resource_statuses.to_json
		}
	end

end
