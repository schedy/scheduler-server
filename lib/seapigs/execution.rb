require './config/environment.rb'

class ExecutionSingle < Producer

	@patterns = [ 'execution-*' ]


	def self.produce(object_id)
		object_id =~ /execution-(\d+)/
		id = $1.to_i
		version = SeapigDependency.versions('Execution','ExecutionStatus','ExecutionValue','Task','TaskStatus','TaskValue')
		data = Execution.detailed_summary(include: ["task_details","artifacts","timeline"], conditions: "e.id = ?", params: [id]).first.description
		version['Seconds#1'] = Time.new.to_i if data["status"] != 'finished'
		[data, version]
	end

end
