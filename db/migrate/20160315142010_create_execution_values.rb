class CreateExecutionValues < ActiveRecord::Migration
  def change
    create_table :execution_values do |t|
      t.integer :execution_id
      t.integer :value_id
      t.timestamp :deleted_at

      t.timestamps null: false
    end
  end
end
