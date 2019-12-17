class AddTaskIdToTaskHooks < ActiveRecord::Migration[5.0]
  def change
    add_column :task_hooks, :task_id, :integer
  end
end
