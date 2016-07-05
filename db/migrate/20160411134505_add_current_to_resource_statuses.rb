class AddCurrentToResourceStatuses < ActiveRecord::Migration
  def change
    add_column :resource_statuses, :current, :boolean
  end
end
