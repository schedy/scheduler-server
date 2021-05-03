require './config/environment.rb'

class ExecutionFilters < Producer
	@patterns = ['execution-filters']

	def self.produce(_seapig_object_id)
		version = SeapigDependency.versions('Execution')
		creators = User.find_by_sql('SELECT DISTINCT users.id, nickname FROM users, executions WHERE users.id = executions.user_id ORDER BY users.nickname')
		tags = Property.find_by_sql('SELECT DISTINCT p.name, v.value FROM properties p, values v, execution_values ev WHERE p.id = v.property_id AND ev.value_id = v.id AND p.id IN (SELECT p.id FROM properties p, execution_values ev, values v WHERE v.property_id = p.id AND ev.value_id = v.id GROUP BY p.id HAVING count(DISTINCT v.id) < 100) ORDER BY p.name, v.value')
		data = {
			creators: creators.map { |creator| creator.nickname },
			tags: tags.map { |tag| tag.name + ':' + tag.value }
		}
		[data, version]
	end
end
