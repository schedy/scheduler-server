class CreateResources < ActiveRecord::Migration
	#resources (id serial primary key, task_id bigint, created_at timestamp, updated_at timestamp, description jsonb);
	def change
		create_table :resources do |t|
			t.integer :task_id
			t.jsonb :description
			
			t.timestamps null: false
		end
	end
end
