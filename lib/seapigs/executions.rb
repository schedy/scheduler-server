require './config/environment.rb'

class Executions < Producer
	@patterns = ['executions-*filtered-*:*']

	#ActiveRecord::Base.logger = Logger.new(STDERR)

	def self.produce(seapig_object_id)
		seapig_object_id =~ /executions-(.*)filtered-([^:]+):(.*)/
		stats = ($1 == 'stats-')
		session_id = $2
		state_id = $3
		version = SeapigDependency.versions('Execution', 'Task')
		session_state_version = SeapigDependency.versions('SeapigRouter::Session::'+session_id)
		sessions = SeapigRouterSession.where(key: session_id)
		return [false, version.merge(session_state_version).merge('Postgres::magic'=>0)] if sessions.size < 1
		states = SeapigRouterSessionState.where(seapig_router_session_id: sessions[0]).where(state_id: state_id)
		return [false, version.merge(session_state_version).merge('Postgres::magic'=>0)] if states.size < 1

		filter = (states[0].state['executions_filter'] or {})
		creator = filter['creator']
		limit = (filter['limit'] or 50)
		created_before = (filter['created_before'] or nil)
		created_after = (filter['created_after'] or nil)
		search_value = filter['search']
		status = filter['status']
		id_after = (filter['id_after'] or nil)
		id_before = (filter['id_before'] or nil)

		tags = {}
		(filter['tags'] or []).each { |tag|
			property, value = tag.split(':', 2)
			(tags[property] ||= []) << value
		}

		conditions = ['true']
		params = []
		includes = []
		if not stats
			includes = ['task_statuses', 'tags']
		end

		if creator
			conditions << 'u.nickname = ?'
			params << creator
		end

		if created_before and (Date.parse(created_before) rescue nil)
			conditions << 'executions.created_at < ?'
			params << created_before
		end

		if created_after and (Date.parse(created_after) rescue nil)
			conditions << '(executions.created_at > ?)'
			params << created_before
		end

		if status and (status.length > 0)
			conditions << "(executions.id IN (SELECT execution_statuses.execution_id FROM execution_statuses WHERE execution_statuses.current = true AND execution_statuses.status ILIKE '%' || ? || '%'))"
			params << status
		end

		if id_before and (id_before.to_i > 0)
			conditions << '(executions.id < ?)'
			params << id_before
		end

		if id_after and (id_after.to_i > 0)
			conditions << '(executions.id > ?)'
			params << id_after
		end

		if search_value and (search_value.to_i > 0)
			conditions << ' (executions.id = ? OR executions.id IN (SELECT t.execution_id FROM tasks t WHERE t.id = ?)) '
			params << search_value
			params << search_value


		elsif search_value and (search_value.length > 1)
			search_value.split().map { |keyword|
				conditions << "executions.id IN (SELECT execution_values.execution_id FROM
				                   execution_values WHERE execution_values.value_id IN
				                                     (SELECT values.id FROM values
				                                      WHERE values.value ILIKE '%' || ? || '%'
				                                     )
				                                )"
				params << keyword
			}
		end

		tags.each_pair { |property, values|
			conditions << "EXISTS ( SELECT * FROM execution_values ev
			        WHERE ev.execution_id = executions.id AND
			              ev.value_id IN (SELECT v.id FROM properties p, values v
			                              WHERE v.property_id = p.id AND p.name = ? AND v.value IN (?)
			                             )
			)"
			params << property
			params << values
		}

		if limit
			includes << 'limit'
			if stats
				params << 1000
			else
				params << limit
			end
		end

		begin
			data = {
				executions: Execution.detailed_summary(include: includes, conditions: conditions.join(' AND '), params: params).to_a.map { |e| e.description }
			}
		rescue ActiveRecord::StatementInvalid
			data = {
				executions: []
			}
		end

		[data, version]
	end
end
