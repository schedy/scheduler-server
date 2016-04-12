require 'active_record'

# create database scheduler_worker;
# create table resources (id serial primary key, task_id bigint, created_at timestamp, updated_at timestamp, description jsonb);
# create table tasks (id bigint primary key, created_at timestamp, updated_at timestamp, status text, pid text, cleaned_at timestamp);
# create table artifacts (id bigint primary key, task_id bigint, actor_id bigint, created_at timestamp, updated_at timestamp, results text, logs text);

module Database
	
	def self.connect
		ActiveRecord::Base.establish_connection(DATABASE)
	end

	def self.disconnect
		ActiveRecord::Base.connection.disconnect!()
	end
	   
	class Resource < ActiveRecord::Base

		def self.free
			self.transaction {
				Resource.where('task_id IS NULL').map { |resource|
					resource.description.merge(id: resource.id)
				}
			}
		end

		def self.free_resource(task_id)

			Resource.where(task_id: task_id).update_all(task_id: nil)	
			connection.instance_variable_get(:@connection).exec("NOTIFY resources_change")
		end

		##LOCKING DOES NOT CHECK IF IT IS ALREADY LOCKED
		## CHECK TRANSACTION BELOW
		def self.lock(task_id,actors)
			self.transaction {
				actors.values.map { |actor|
					target_resource = Resource.find(actor[:id])
					if target_resource.task_id == nil
						target_resource.update(task_id: task_id)
					else
						p 'Resource is already locked !'
					end
				}
			}
			connection.instance_variable_get(:@connection).exec("NOTIFY resources_change")
		end		

	end


	class Task < ActiveRecord::Base

	end

	
end


