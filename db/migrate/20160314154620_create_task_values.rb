class CreateTaskValues < ActiveRecord::Migration
  def change
    create_table :task_values do |t|
      t.integer :task_id
      t.integer :value_id
      t.timestamp :deleted_at

      t.timestamps null: false
    end
  end
end
