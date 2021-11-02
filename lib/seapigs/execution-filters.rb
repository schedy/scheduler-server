require './config/environment.rb'

class ExecutionFilters < Producer
	@patterns = ['execution-filters']

	def self.produce(_seapig_object_id)
		version = SeapigDependency.versions('Execution')
		creators = User.find_by_sql('SELECT DISTINCT users.id, nickname FROM users, executions WHERE users.id = executions.user_id ORDER BY users.nickname')
		tags = Property.find_by_sql('SELECT DISTINCT p.name, v.value FROM properties p, values v, execution_values ev WHERE p.id = v.property_id AND ev.value_id = v.id AND p.id IN (SELECT p.id FROM properties p, execution_values ev, values v WHERE v.property_id = p.id AND ev.value_id = v.id GROUP BY p.id HAVING count(DISTINCT v.id) < 100) ORDER BY p.name, v.value')
		popular_tags = Property.find_by_sql("select jsonb_array_elements(state#>'{executions_filter,tags}') as tag from seapig_router_session_states where state#>'{executions_filter,tags}' is not null and jsonb_array_length(state#>'{executions_filter,tags}') > 0 and now()-created_at < '3 month'::interval group by jsonb_array_elements(state#>'{executions_filter,tags}') order by count(*) desc limit 10;")
		data = {
			creators: creators.map { |creator| creator.nickname },
			tags: tags.map { |tag| tag.name + ':' + tag.value },
			popular_tags: popular_tags
		}
		[data, version]
	end
end
