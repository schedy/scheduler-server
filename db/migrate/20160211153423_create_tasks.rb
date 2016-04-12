class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.integer :execution_id
      t.jsonb :description

      t.timestamps null: false
    end
  end
end
