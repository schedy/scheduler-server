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
            terminal_url: "http://localhost:2222" + "/ssh/host/" + worker.status.data["ip"],
            resources: worker.status.data["resources"].filter_map { |r| r.merge({ "execution_id" => (Task.find_by(id: r["task_id"]).execution_id or "none") }) if r["task_id"].to_i > 0 }
          }
        }
      }
      [data, version]
    }
  end
end
