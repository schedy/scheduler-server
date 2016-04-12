class CreateTaskStatuses < ActiveRecord::Migration
  def change
    create_table :task_statuses do |t|
      t.integer :task_id
      t.text :status
      t.boolean :current

      t.timestamps null: false
    end
  end
end
