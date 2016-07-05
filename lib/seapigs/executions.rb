require './config/environment.rb'

class Executions < Producer

	@patterns = [ 'executions-filtered-*:*' ]

#	ActiveRecord::Base.logger = Logger.new(STDERR)
	def self.produce(object_id)
		object_id =~ /executions-filtered-([^:]+):(.*)/
		session_id = $1
		state_id = $2
		version = SeapigDependency.versions('Execution','ExecutionValue','Task','TaskStatus','TaskValue')
		session_version = SeapigDependency.version('SeapigRouterSession')
		session_state_version = SeapigDependency.version('SeapigRouterSessionState#'+session_id)
		sessions = SeapigRouterSession.where(key: session_id)
		return [false, version.merge(SeapigRouterSession: session_version, 'SeapigRouterSessionState#'+session_id => session_state_version)] if sessions.size < 1
		states = SeapigRouterSessionState.where(seapig_router_session_id: sessions[0]).where(state_id: state_id)
		return [false, version.merge(SeapigRouterSession: session_version, 'SeapigRouterSessionState#'+session_id => session_state_version)] if states.size < 1

		filter = (states[0].state["executions_filter"] or {}) 
		creator = filter["creator"]
		limit = filter["limit"]
		tags = {}
		(filter["tags"] or []).each { |tag|
			property,value = tag.split(":",2)
			(tags[property] ||= []) << value
		}

		conditions = [ "true" ]
		params = []
		includes = []
		
		if creator
			conditions << "u.nickname = ?"
			params << creator
		end

		tags.each_pair { |property,values|
			conditions << "EXISTS (SELECT * FROM execution_values ev WHERE ev.execution_id = e.id AND ev.value_id IN (SELECT v.id FROM properties p, values v WHERE v.property_id = p.id AND p.name = ? AND v.value IN (?)))"
			params << property
			params << values
		}
		
		if limit
			includes << "limit"
			params << limit
		end

		data = {
			executions: Execution.detailed_summary(include: includes, conditions: conditions.join(" AND "), params: params).to_a.map { |e| e.description }
		}
		
		[data, version]
	end

end
