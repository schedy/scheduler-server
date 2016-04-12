#!/bin/env ruby


require 'set'
require 'seapig-client'
require 'pp'

require './config.rb'

EM.run {
	
	
	seapig_server = SeapigServer.new(SEAPIG_URI, name: "dealer")

	worker_estimates = seapig_server.slave('estimates:*')
	tasks_waiting = seapig_server.slave('tasks-waiting')
	assignments = Hash.new { |hash,key| hash[key] = seapig_server.master('assignments:'+key) }
	
	redeal = true
	tasks_waiting.onchange { redeal = true }
	worker_estimates.onchange { redeal = true }

	EM.add_periodic_timer(1) {
		next if (not redeal) or (not tasks_waiting.valid)

#		pp worker_estimates

		scores = []
		worker_estimates.each_pair { |worker, estimates|
			estimates.each { |task_id,estimate|
				scores << [estimate["estimate"], (estimate["actors"].size*(-1)), task_id, worker.split(':')[1]]
			}
		}
		scores.sort!

		p tasks_waiting['tasks'].map { |a| a["id"] }

		assigned = Set.new(assignments.values.map { |assignments| assignments.keys }.flatten)
		used_stations = Set.new
		assigned_tasks = Set.new
		waiting_task_ids = tasks_waiting['tasks'].map { |task| task['id'].to_s }
		scores.each { |estimate, actor_count, task_id, worker|
			next if assigned.include?(task_id)
			next if used_stations.include?(worker)
			next if assigned_tasks.include?(task_id)
			next if not waiting_task_ids.include?(task_id)
			assignments[worker][task_id] = tasks_waiting['tasks'].find { |task| task['id'].to_s == task_id }.merge(assigned_at: Time.new)
			used_stations << worker
			assigned_tasks << task_id
		}

		assignments.each_pair { |worker, worker_assignments|
			worker_assignments.each_pair { |id,assignment|
				worker_assignments.delete(id) if not tasks_waiting['tasks'].find { |task| task['id'].to_s == id.to_s }
			}
			worker_assignments.changed
		}

#		p assignments
		
		redeal = false
	}


	EM.add_periodic_timer(1) {

#		p :pre_cleaning, assignments
		assignments.each_pair { |worker, worker_assignments|
			worker_assignments.each_pair { |id,assignment|
				next if assignment[:assigned_at] > Time.new - 30
				puts "Timeout on "+assignment.inspect+" - requeuing"
				worker_assignments.delete(id)
				redeal = true
			}
		}
		p :post_cleaning, assignments if redeal

	}
}



