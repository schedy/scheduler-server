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
            ip: worker.status.data["ip"],
            name: worker.name,
            last_status_update: worker.status.created_at,
            resources: worker.status.data['resources'].map { |r| (!r['task_id']&.nonzero?) ? r : r.merge!({"execution_id":(Task.find(r["task_id"]).execution_id)}) }.sort_by { |r| r["type"] }
          }
        }
      }
      [data, version]
    }
  end
end
