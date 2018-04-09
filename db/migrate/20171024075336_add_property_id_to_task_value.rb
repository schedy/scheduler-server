class AddPropertyIdToTaskValue < ActiveRecord::Migration[5.0]
  def change
    remove_column :task_values, :deleted_at
    add_column :task_values, :property_id, :integer
    execute 'create index on values(id, property_id)'
    execute 'update task_values set property_id = (select v.property_id from values v where task_values.value_id = v.id)'
  end
end
