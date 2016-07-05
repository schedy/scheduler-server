class ExecutionStatusesController < ApplicationController
  def create
    task_id = params[:task_id]
    actors = params[:actors]
    execution_status = ExecutionStatus.new

    if not actors.blank?
      execution_status.description = actors      
    end

  end
end
