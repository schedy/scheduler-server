require './config/environment.rb'

class Tasks < Producer

  @patterns = [ 'tasks-waiting' ]

  def self.produce(object_id)

    #		ActiveRecord::Base.logger = Logger.new(STDERR)

    Task.uncached {
      version = SeapigDependency.versions('Task','TaskStatus')
      data = {
        tasks: Task.joins(:task_statuses).where(task_statuses: { current: true }).where(task_statuses: { status: 'waiting' }).map { |task|
          task.description.merge(
            id: task.id,
            execution_id: task.execution_id
          )
        }
      }
      [data, version]
    }
  end

end
