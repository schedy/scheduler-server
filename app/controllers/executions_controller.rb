class ExecutionsController < ApplicationController

  skip_before_filter :verify_authenticity_token, only: :create

  def create
    execution = Execution.create_with_tasks(params[:execution])
    summary = Execution.detailed_summary(include: ["task_details","task_artifacts","artifacts"], conditions: "e.id = ?", params: [execution.id]).first.description
    respond_to { |format|
      format.json { render json: summary }
    }
  end


  def show
    execution = Execution.find(params[:id])
    summary = Execution.detailed_summary(include: ["task_details","task_artifacts","artifacts"], conditions: "e.id = ?", params: [execution.id]).first.description
    respond_to { |format|
      format.json { render json: summary }
    }
  end


  def duplicate
    execution_id = params[:execution_id]
    original_execution = Execution.find(execution_id)
    duplicate_execution = original_execution.dup
    original_tasks = original_execution.tasks

    original_tasks.each { |task|
      duplicate_task = task.dup
      duplicate_task.save
      TaskStatus.create!(task_id: duplicate_task.id, status: "waiting", current: true)
      duplicate_execution.tasks << duplicate_task
    }

    original_execution_hooks = original_execution.execution_hooks
    original_execution_hooks.each { |hook|
      duplicate_hook = hook.dup
      duplicate_hook.save
      duplicate_execution.execution_hooks << duplicate_hook
    }

    original_execution_values = original_execution.execution_values
    original_execution_values.each { |execution_value|
      duplicate_execution_value = execution_value.dup
      duplicate_execution_value.save
      duplicate_execution.execution_values << duplicate_execution_value

    }

    duplicate_execution.save
    ExecutionStatus.create!(execution_id: duplicate_execution.id, current: true, status: "waiting")
    duplicate_execution.update_status
    SeapigDependency.bump("Execution","Task","TaskStatus")
    render json: duplicate_execution
  end

  def force_status
    execution_id = params[:execution_id]
    options = params[:options]
    target_tasks = Task.find_by_sql( "SELECT id FROM tasks WHERE execution_id = #{execution_id}")
    target_tasks.map { |task|
      # XXX: Line below can be improved..
      if task.status.status =~ /waiting/
        task.status.update(current: false)
        TaskStatus.create!({task_id: task.id, current: true, status: options})
      end
    }
    SeapigDependency.bump('TaskStatus')
    Execution.find(execution_id).update_status
    render json: target_tasks
  end

end
