require "./config/environment.rb"

class Workers < Producer
	@patterns = ["workers"]

	def self.produce(_seapig_object_id)
		Worker.uncached {
			version = SeapigDependency.versions("Worker")
			data = {
				workers: Worker.joins(:worker_statuses).where(worker_statuses: { current: true }).where("data IS NOT NULL").order("name").map { |worker|
					{
						id: worker.id,
						ip: (worker.status.data["ip"].split("&").grep(/10\./).first or "none"), ##TODO: Fetch correct IP with a better method.
						name: worker.name,
						last_status_update: worker.status.created_at.to_time.iso8601,
						resources: worker.status.data["resources"].map { |r| (!r["task_id"]&.nonzero?) ? r : r.merge!({ "execution_id": (Task.find(r["task_id"]).execution_id) }) }.map { |r| if Resource.find_by(worker_id: worker.id, remote_id: r["id"]) then r.merge!({ "options": Resource.find_by(worker_id: worker.id, remote_id: r["id"])&.status&.description["options"], "icon": "https://robohash.org/" + Digest::SHA1.hexdigest([Resource.find_by(worker_id: worker.id, remote_id: r["id"]).status.description["type"], Resource.find_by(worker_id: worker.id, remote_id: r["id"]).status.description["options"]].join) }) else r end }.sort_by { |r| r["type"] },
					}
				},
			}
			[data, version]
		}
	end
end
