class ChangeColumnName < ActiveRecord::Migration
  def change
	rename_column :resource_statuses, :name, :event
  end
end
