require './config/environment.rb'

class Workers < Producer

	@patterns = [ 'workers' ]

	def self.produce(object_id)

		Worker.uncached {
			version = SeapigDependency.versions('Worker','WorkerStatus')
			data = {
				workers: Worker.joins(:worker_statuses).where(worker_statuses: { current: true }).where("data IS NOT NULL").order("name").map { |worker|
					{
						id: worker.id,
# TODO: FIX it...
#            ip: worker.ip,
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
