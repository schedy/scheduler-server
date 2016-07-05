class ResourceStatuses < ActiveRecord::Migration
  def change
    create_table :resource_statuses do |t|
        t.integer :task_id
        t.jsonb :description
        t.integer :resource_id
        t.text :name
        t.timestamps null: false
    end
  end
end







