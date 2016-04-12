class Device < Manager::Resource

	def self.estimate(candidate, required)
		#p :x

#		return nil if (candidate[:tasks] or 0) >= candidate[:count]

		estimate = if not required[:image] or candidate[:image] == required[:image]
				   0
			   else
				   60
			   end
#
#		resources = plan[:resources].map { |resource|
#			next resource if resource[:id] != candidate[:id]
#			resource.merge(tasks: candidate[:tasks] + 1)
		#		}

#		resources = plan[:resources] #.dup
#		resources[i] = candidate.merge(tasks: candidate[:tasks] + 1)

#		actors = (required[:role] and plan[:actors].merge(required[:role] => candidate) or plan[:actors])

#		actors = {}
#		{
#			resources: resources,
#			estimate: estimate,
#			actors: actors,
#			steps: plan[:steps]
#		}
	end

	def self.transition(owned, required)

	end


end
