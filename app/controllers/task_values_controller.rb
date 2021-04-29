class TaskValuesController < ApplicationController

	skip_before_action :verify_authenticity_token, only: :create

	def create
		Task.transaction {
			task = Task.find(params[:task_id])
			raise 'Property or you are asked to leave...!' if (not params[:property]) or (params[:property].size == 0)
			return render json: {}  if (not params[:value]) or (params[:value].size == 0)
			property = Property.find_or_create_by!(name: params[:property])
			value = Value.find_or_create_by!(property_id: property.id, value: params[:value])
			task_value = task.task_values.where(value_id: value.id).first
			task_value = TaskValue.create!(task_id: task.id, value_id: value.id, property_id: property.id) if not task_value
			SeapigDependency.bump('TaskValue', 'Execution:%010i'%[task.execution_id])

			render json: { id: task_value.id }
		}
	end

end
