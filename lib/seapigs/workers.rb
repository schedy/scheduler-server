require './config/environment.rb'

class Workers < Producer

	@patterns = [ 'workers' ]

	def self.produce(object_id)

		Worker.uncached {
			version = {
				Worker: Worker.seapig_dependency_version,
				WorkerStatus: WorkerStatus.seapig_dependency_version
			}
			data = {
				workers: Worker.joins(:worker_statuses).where(worker_statuses: { current: true }).map { |worker|
					{
						name: worker.name,
						last_status_update: worker.status.created_at,
						resources: worker.status.data["resources"].sort_by { |resource| resource["id"] }
					}
				}
			}
			[data, version]
		}
	end

end
