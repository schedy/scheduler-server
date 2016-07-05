class Resources < ActiveRecord::Migration
  def change
    create_table :resources do |t|
        t.integer :worker_id
        t.integer :remote_id
        t.text :name
        t.timestamps null: false
    end
  end
end




