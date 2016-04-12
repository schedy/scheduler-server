require './config/environment.rb'

class ExecutionSingle < Producer

	@patterns = [ 'execution-*' ]


	def self.produce(object_id)
		object_id =~ /execution-(\d+)/
		id = $1.to_i
		version = {
			Execution: Execution.seapig_dependency_version,
			ExecutionStatus: ExecutionStatus.seapig_dependency_version,
			ExecutionValue: ExecutionValue.seapig_dependency_version,
			Task: Task.seapig_dependency_version,
			TaskStatus: TaskStatus.seapig_dependency_version,
			TaskValue: TaskValue.seapig_dependency_version,
			Second: Time.new.to_i
		}
		data = Execution.detailed_summary(include: ["task_details"], conditions: "e.id = ?", params: [id]).first.description
		[data, version]
	end

end
