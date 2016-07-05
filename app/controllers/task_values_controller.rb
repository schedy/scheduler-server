class TaskValuesController < ApplicationController

	skip_before_filter :verify_authenticity_token, only: :create

	def create
		Task.transaction {
			task = Task.find(params[:task_id])
			raise "Property or gtfo!" if (not params[:property]) or (params[:property].size == 0)
			raise "Value is missing, pls gif" if (not params[:value]) or (params[:value].size == 0)
			property = Property.find_or_create_by!(name: params[:property])
			value = Value.find_or_create_by!(property_id: property.id, value: params[:value])
			task_value = task.task_values.where(value_id: value.id).first
			task_value = TaskValue.create!(task_id: task.id, value_id: value.id) if not task_value
			SeapigDependency.bump('TaskValue')
			
			render json: { id: task_value.id }
		}
	end

end
