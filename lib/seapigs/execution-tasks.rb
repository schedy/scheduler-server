require './config/environment.rb'
require 'uri'
require 'base64'

def base64decode(text)
	URI.decode_www_form_component(Base64.decode64(text))
end

class ExecutionTasks < Producer
	@patterns = [ 'execution-tasks-filtered-*:*' ]

	#ActiveRecord::Base.logger = Logger.new(STDERR)

	def self.produce(seapig_object_id)
		seapig_object_id =~ /execution-tasks-filtered-([^:]+):(.*)/
		session_id = $1
		state_id = $2
		
		session_state_version = SeapigDependency.versions('SeapigRouter::Session::'+session_id).merge('Postgres::magic'=>0)
		sessions = SeapigRouterSession.where(key: session_id)
		return [false, session_state_version] if sessions.size < 1
		states = SeapigRouterSessionState.where(seapig_router_session_id: sessions[0]).where(state_id: state_id)
		return [false, session_state_version] if states.size < 1

		filter = (states[0].state['task_list_filter'] or {})
		execution_id = (states[0].state['execution_id'] or '1').gsub(/[^0-9]/, '') #meh
		version = SeapigDependency.versions('Execution:%010i'%[execution_id])

		includes = ['task', 'task_filter', 'task_resources', 'task_worker', 'task_tags']
		conditions = [ 'true' ]
		params = []

		properties_to_check = []
		properties_required = []
		prohibited_values = []
		filter.to_a.each { |property, values|
			if property = Property.find_by(name: base64decode(property))
				new_prohibited_values = property.values.where(value: values.to_a.select { |value, filter_out| filter_out == 't' }.map { |value, _| base64decode(value)}).map(&:id)
				prohibited_values += new_prohibited_values
				properties_to_check << property.id.to_i
				properties_required << property.id.to_i    if values['LQ'] == 't'
			end
		}

		params << properties_to_check
		params << [-1]+prohibited_values
		params << properties_required

		conditions << 'executions.id = ?'
		params << execution_id

		data = (Execution.detailed_summary(include: includes, conditions: conditions.join(' AND '), params: params).first&.description or {})

		[data, version]
	end
end
