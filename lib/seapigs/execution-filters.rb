require './config/environment.rb'

class ExecutionFilters < Producer

	@patterns = [ 'execution:filters' ]


	def self.produce(object_id)
		version = {
			Execution: Execution.seapig_dependency_version,
		}
		creators = User.find_by_sql("SELECT DISTINCT users.id, nickname FROM users, executions WHERE users.id = executions.user_id ORDER BY users.nickname")

		data = {
			creators: creators.map { |creator| creator.nickname }
		}
		[data, version]
	end

end
