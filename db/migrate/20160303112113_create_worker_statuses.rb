class CreateWorkerStatuses < ActiveRecord::Migration
  def change
    create_table :worker_statuses do |t|
	    t.integer :worker_id
	    t.boolean :current
      t.jsonb :data

      t.timestamps null: false
    end
  end
end
