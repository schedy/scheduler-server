#!/bin/env ruby


# Resources and Requirements trees are PORO to speed up duplication.
# Resources tree is 2-levels to speed up duplication.
#
# Resources in the same forest have to be independent (estimate values need to be independent variables), otherwise shit goes bad at 4-of-16 selection (4s/est).
require 'munkres'

module Manager

	class Resource; end
		
	Dir['./resources/*.rb'].each { |file| require file }
	RESOURCE_TYPES = Hash[*ObjectSpace.each_object(Class).select { |klass| klass < Resource }.map { |klass| [klass.name.to_s, klass] }.flatten]


	# Recursion avoidance makes this a bit messy, sry
	

	def self.estimate(current_forest, required_forest)
		begin
			plan = {
				resources: current_forest,
				estimate: 0,
				actors: {},
				steps: []
			}

			return plan if (required_forest.size == 0)
			return nil if required_forest.size > current_forest.size

			best_steps = []		
			best_plan = nil
			new_actors = {}
			estimated_times = []
			estimates_by_resource_by_requirement = []
			
			matrix = required_forest.each_with_index.map { |requirement, requirement_i|
				current_forest.each_with_index.map { |resource, resource_i|
					next 1.0/0 if requirement["type"] != resource["type"]
					#DO NOT FAIL LIKE THIS.
					RESOURCE_TYPES[resource["type"]].estimate(resource, requirement)

				}
			}

			
			m_l = matrix.length
			m_h = matrix[0].length

			#Dirty padding.
			if (m_h-m_l > 0)
				df = m_h - m_l
				for i in 0..df-1 
					matrix.push(Array.new.fill(0,0..m_h-1))
				end
			end
			#Debug pieces.
			puts matrix.to_s
			puts required_forest
			puts current_forest
			
			#Copy matrix from destructive Munkres.
			m1 = matrix.map{|row| row.map { |e| e[0]  }.dup}
			
			m2 = matrix.map{|row| row.map { |e| e[0]  }.dup}
			
			m3 = matrix.map{|row| row.map { |e| e[1]  }.dup}

			puts 'Main matrix:'
			puts m2
			if matrix.flatten.include?(Float::INFINITY) then return nil else m = Munkres.new(m2) end
			#Find minimum cost indices.
			optimum_values_indices = m.find_pairings
			#Map indices on matrix.
			optimum_values_indices.each { |req_i,res_i|
				next if req_i >= required_forest.size					
				estimated_times.push(m1[req_i][res_i])
				
				new_actors[required_forest[req_i]["role"]] = current_forest[res_i]
				
				best_steps.push(m3[req_i][res_i])
			}
			puts 'M3:'
			puts m3
			#Construct best plan.
			best_plan = {
				estimate: estimated_times.max,
				actors: new_actors,
				steps: best_steps
			}
			best_plan
		end
		
	end


	def self.transition(steps)
		puts "Transition begins."		
		##PARALLEL FLASHING
		steps.each { |step|
				RESOURCE_TYPES[step[:resource]["type"]].transition(step[:resource],step[:required],step[:steps])
		}
		

	end
	
end


