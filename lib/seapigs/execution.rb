require './config/environment.rb'

class ExecutionSingle < Producer

	@patterns = [ 'execution:*' ]


	def self.produce(seapig_object_id)
		seapig_object_id =~ /execution:(\d+)/
		id = $1.to_i
		version = SeapigDependency.versions('Execution:%010i'%[id])
		data = Execution.detailed_summary(include: ["task_tag_stats","task_statuses","artifacts","hooks","tags"], conditions: "executions.id = ?", params: [id]).first
		data = data.description if data
		data = {} if not data
		[data, version]
	end

end
