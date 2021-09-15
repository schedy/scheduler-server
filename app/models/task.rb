class Task < ActiveRecord::Base
	belongs_to :execution
	has_many :task_statuses
	has_one :status, ->{ where current: true }, class_name: 'TaskStatus'
	has_many :artifacts
	has_many :task_values
	has_many :resource_statuses
	has_many :task_hooks
	belongs_to :requirement
	has_many :hook_runs

	def self.create_from_description(execution, task_descriptions)
		return if not task_descriptions or task_descriptions.size == 0
		raise 'Task descriptions need requirements, sry' if task_descriptions.find { |description| not description['requirements'] }

		properties = Hash.new { |h, k| h[k] = Property.find_or_create_by!(name: k) }
		values = Hash.new { |h, k| h[k] = Value.find_or_create_by!(property_id: k[0] , value: k[1]) }

		requirements_by_hash = task_descriptions.map { |description| [description['requirements'].hash, description['requirements']] }.to_h
		Requirement.connection.execute('CREATE TEMPORARY TABLE requirements_to_assert (uuid, ruby_hash, description) AS SELECT md5(vals.descr::jsonb::text)::uuid, vals.rh::bigint, vals.descr::jsonb FROM (VALUES %s) AS vals (rh, descr)'%[requirements_by_hash.to_a.map { |hash, data| '('+hash.to_s+',\''+Execution.connection.quote_string(JSON.dump(data))+'\')' }.join(',')])
		Requirement.connection.execute('INSERT INTO requirements (uuid, description, created_at, updated_at) SELECT rta.uuid, rta.description, now(), now() FROM requirements_to_assert rta  ON CONFLICT (uuid) DO NOTHING')
		requirement_ids_by_hash = Requirement.connection.execute('SELECT rta.ruby_hash, r.id FROM requirements r, requirements_to_assert rta WHERE rta.uuid = r.uuid').to_a.map { |row| [row['ruby_hash'], row['id']] }.to_h
		Requirement.connection.execute('DROP TABLE requirements_to_assert')

		task_params_group = []
		task_descriptions.each { |description|
			requirement_id = requirement_ids_by_hash[description['requirements'].hash]
			description.delete('requirements')
			task_params_group.push(['('+execution.id.to_s, requirement_id, "'"+Execution.connection.quote_string(JSON.dump(description))+"'", 'now()', 'now())'])
		}

		tasks = Task.find_by_sql('WITH new_tasks AS (                                                                      '+
								'        INSERT INTO tasks(execution_id,requirement_id,description,created_at,updated_at) '+
								"        VALUES #{task_params_group.join(',')}                                            "+
								'        RETURNING id)                                                                    '+
								'INSERT INTO task_statuses (task_id,status,current,created_at,updated_at)                 '+
								"SELECT id,'waiting',true,now(),now()                                                     "+
								'FROM new_tasks                                                                           '+
								'RETURNING task_id                                                                        ')

		task_values = []
		[tasks, task_descriptions].transpose.each { |task, task_params|
			if task_params['hooks']
				task_params['hooks'].each_pair { |k, v|
						TaskHook.create!(task_id: task.task_id, hook: v, status: k)
				}
			end
			 (task_params['tags'] or {}).each_pair { |property_name, tag_names|
				tag_names.uniq.each { |value_name|
					 property = properties[property_name]
					 value = values[[property.id, value_name]]
					 task_values.push("(#{task.task_id},#{value.id},#{property.id},now(),now())")
				}
			 }

		 }

		TaskValue.connection.execute('INSERT INTO task_values(task_id,value_id,property_id,created_at,updated_at) VALUES '+task_values.join(','))
		
		tasks.map { |task| task.task_id }
	end

	def trigger_hooks(status)
		self.task_hooks.where(status: status).each { |hook|
			Thread.new {
				hook_run = HookRun.run_hook(hook.hook, "task instance", status, self.id, [self.id.to_s, status], "")
				hook.hook_run = hook_run
			}
		}
	end

	def duplicate
		Task.create_from_description(self.execution, [self.description.merge('requirements' => self.requirement.description)])[0]
	end
end
