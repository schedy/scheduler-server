class CreateExecutionHooks < ActiveRecord::Migration
  def change
    create_table :execution_hooks do |t|
      t.integer :execution_id
      t.text :status
      t.text :hook

      t.timestamps null: false
    end
  end
end
