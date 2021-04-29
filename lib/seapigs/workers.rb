require './config/environment.rb'

class Workers < Producer

	@patterns = [ 'workers' ]

	def self.produce(seapig_object_id)

		Worker.uncached {
			version = SeapigDependency.versions('Worker')
			data = {
				workers: Worker.joins(:worker_statuses).where(worker_statuses: { current: true }).where('data IS NOT NULL').order('name').map { |worker|
					{
						id: worker.id,
						ip: worker.status.data['ip'],
						name: worker.name,
						last_status_update: worker.status.created_at,
						resources: (worker.status.data['resources'] or []).sort_by { |resource| resource['id'] }
					}
				}
			}
			[data, version]
		}
	end

end
