class CreateTasks < ActiveRecord::Migration
	#tasks (id bigint primary key, created_at timestamp, updated_at timestamp, status text, pid text, cleaned_at timestamp);
	def change
		create_table :tasks do |t|
			t.text :status
			t.integer :pid
			t.timestamp :cleaned_at
			
			t.timestamps null: false
		end
	end
end
