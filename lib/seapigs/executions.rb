require './config/environment.rb'

class Executions < Producer

	@patterns = [ 'executions-filtered-*:*' ]

	ActiveRecord::Base.logger = Logger.new(STDERR)
	def self.produce(object_id)
		object_id =~ /executions-filtered-([^:]+):(.*)/
		session_id = $1
		state_id = $2
		version = {
			Execution: Execution.seapig_dependency_version,
			ExecutionValue: ExecutionValue.seapig_dependency_version,
			Task: Task.seapig_dependency_version,
			TaskStatus: TaskStatus.seapig_dependency_version,
			TaskValue: TaskValue.seapig_dependency_version
		}
		session_version = SeapigRouterSession.seapig_dependency_version
		session_state_version = SeapigRouterSessionState.seapig_dependency_version
		sessions = SeapigRouterSession.where(key: session_id)
		return [false, version.merge(SeapigRouterSession: session_version, SeapigRouterSessionState: session_state_version)] if sessions.size < 1
		states = SeapigRouterSessionState.where(seapig_router_session_id: sessions[0]).where(state_id: state_id)
		return [false, version.merge(SeapigRouterSession: session_version, SeapigRouterSessionState: session_state_version)] if states.size < 1

		filter = (states[0].state["executions_filter"] or {}) 
		creator = filter["creator"]
		limit = filter["limit"]


		conditions = [ "true" ]
		params = []
		includes = []
		
		if creator
			conditions << "u.nickname = ?"
			params << creator
		end
			
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
