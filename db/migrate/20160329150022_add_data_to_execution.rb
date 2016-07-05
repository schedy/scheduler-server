class AddDataToExecution < ActiveRecord::Migration
  def change
    add_column :executions, :data, :jsonb
  end
end
