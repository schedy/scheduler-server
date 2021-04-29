class TaskStatusesController < ApplicationController

	skip_before_action :verify_authenticity_token, only: :create

	def create

		constraint_matrix = [
			[ 'waiting','assigned' ],
			[ 'assigned','assigned' ],
			[ 'assigned','accepted' ],
			[ 'accepted','waiting' ],
			[ 'accepted','transition' ],
			[ 'transition','crashed' ],
			[ 'transition','failed' ],
			[ 'transition','timeout' ],
			[ 'transition','started' ],
			[ 'started','crashed' ],
			[ 'started','failed' ],
			[ 'started','timeout' ],
			[ 'started','finished' ]
		]

		worker = Worker.find_or_create_by(name: (params[:worker] or params[:worker_id])) if params[:worker] or params[:worker_id]

		raise if not params[:task_id]
		if params[:task_id] =~ /\d+/
			tasks_query = [ 'id = ?', params[:task_id] ]
			old_status = Task.find(params[:task_id]).status.status
		else # no locking here yet, since we assume client has sole authority to alter resulting records
			#tasks_query = [ "exists (select * from task_statuses ts where ts.current and ts.task_id = tasks.id and ts.worker_id = ? and ts.status = ?)", worker.id, params[:task_id] ]
			tasks_query = [ "exists (select * from task_statuses ts where ts.current and ts.task_id = tasks.id and ts.worker_id = #{worker.id.to_i} and ts.status = '#{Execution.connection.quote_string(params[:task_id])}')" ]
			old_status = params[:task_id]
		end

		new_status = params[:status]
		actors = params[:actors]

		#INFO: If request cannot satisfy constraint matrix, return 423 - Locked.
		if ((not params[:force]) and constraint_matrix.index([old_status,new_status]).nil?) or !constraint_matrix.find { |old,new| new == new_status }
			render nothing: true , status: 423
			return
		end

		task_ids = []
		executions = Task.where(*tasks_query).map { |task| task.execution }.uniq
		executions.each { |execution|
			execution.with_lock {
				Task.uncached {

					Task.where(*tasks_query).where(execution_id: execution.id).each { |task|
						task_ids << task.id
						task.status.update(current: false)
						task_status = TaskStatus.create!(task_id: task.id, current: true, status: new_status, worker_id: worker ? worker.id : nil)

						if actors
							actors.values.each { |actor|
								resource = Resource.find_or_create_by(remote_id: actor, worker_id: worker.id )
								resource.task_statuses << task_status
								resource.save
							}
						end
						task.trigger_hooks(new_status)

						if new_status == 'crashed' and (task.retry || 0) < 1
							new_task = Task.find(task.duplicate)
							new_task.retry = (task.retry || 0) + 1
							new_task.save
						end
					}
					execution.update_status(true)

				}



			}
		}

		seapig_dependency_versions = SeapigDependency.bump('Task', *executions.map { |execution| 'Execution:%010i'%[execution.id] })
		seapig_dependency_versions.merge! SeapigDependency.bump('Task:waiting') if old_status == 'assigned' or new_status == 'assigned' or old_status == 'waiting' or new_status == 'waiting'
		seapig_dependency_versions.merge! SeapigDependency.bump('Task:assigned:'+worker.name) if (new_status == 'assigned' or old_status == 'assigned') and worker

		render json: { seapig_dependency_versions: seapig_dependency_versions, tasks: task_ids }

	end

end
