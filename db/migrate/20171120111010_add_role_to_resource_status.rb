class AddRoleToResourceStatus < ActiveRecord::Migration[5.0]
  def change
    add_column :resource_statuses, :role, :text
  end
end
