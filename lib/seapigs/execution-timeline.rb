require './config/environment.rb'

class ExecutionTimeline < Producer
	@patterns = ['execution-timeline:*']

	def self.produce(seapig_object_id)
		seapig_object_id =~ /execution-timeline:(\d+)/
		id = $1.to_i
		version = SeapigDependency.versions('Execution:%010i'%[id])
		data = Execution.detailed_summary(include: ['task', 'timeline','tags'], conditions: 'executions.id = ?', params: [id]).first.description
		[data, version]
	end
end
