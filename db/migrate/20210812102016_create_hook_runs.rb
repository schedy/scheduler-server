class CreateHookRuns < ActiveRecord::Migration[6.1]
  def change
    create_table :hook_runs do |t|
      t.string :name
      t.text :entity_type
      t.text :entity_state
      t.integer :execution_id
      t.integer :task_id
      t.text :arguments, array:true, default: []
      t.integer :exit_code
      t.timestamp :finished_at

      t.timestamps
    end

    change_table :artifacts do |t|
      t.integer :hook_run_id
      t.index :hook_run_id, where: "(hook_run_id IS NOT NULL)"
    end
    change_table :execution_hooks do |t|
      t.integer :hook_run_id
    end
    change_table :task_hooks do |t|
      t.integer :hook_run_id
      t.index :hook_run_id, where: "(hook_run_id IS NOT NULL)"
    end
  end
end
