class CreateExecutionStatuses < ActiveRecord::Migration
  def change
    create_table :execution_statuses do |t|
      t.integer :execution_id
      t.text :status
      t.boolean :current

      t.timestamps null: false
    end
  end
end
