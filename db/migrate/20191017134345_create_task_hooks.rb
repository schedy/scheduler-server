class CreateTaskHooks < ActiveRecord::Migration[5.0]
  def change
    create_table :task_hooks do |t|
      t.timestamps
      t.text :hook
      t.text :status
      t.integer :execution_id
    end
  end
end
