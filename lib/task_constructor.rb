#!/bin/ruby

require 'awesome_print'

class TaskProcedure
	
	def self.descendants
		puts "Fetching all task procedures.."
		ObjectSpace.each_object(Class).select { |klass| klass < self }
	end

	def self.create_tasks(workitem)
		tasks = nil
		project = workitem["payload"]["project"]
		package = workitem["payload"]["package"]
		
		self.descendants.each { |resource|
			puts "Composing tasks out of workitems.."
			temp = resource.initiate(workitem)
			if temp
				tasks = temp
			end
		}
		if not tasks
			raise "Unknown project/package ! "+workitem.inspect		
		end
		tasks

	end

	

	
end

Dir["./lib/task_procedures/*.rb"].each { |e| require(e) }
