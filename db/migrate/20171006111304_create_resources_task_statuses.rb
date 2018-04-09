class CreateResourcesTaskStatuses < ActiveRecord::Migration[5.0]
  def change
    create_table :resources_task_statuses do |t|
      t.integer :resource_id
      t.integer :task_status_id
    end
  end
end
