class AddPropertyIdToExecutionValue < ActiveRecord::Migration[5.0]
  def change
    remove_column :execution_values, :deleted_at
    add_column :execution_values, :property_id, :integer
    execute 'update execution_values set property_id = (select v.property_id from values v where execution_values.value_id = v.id)';
  end
end
