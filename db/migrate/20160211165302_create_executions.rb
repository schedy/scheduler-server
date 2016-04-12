class CreateExecutions < ActiveRecord::Migration
  def change
    create_table :executions do |t|
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
