class CreateSeapigRouterSessions < ActiveRecord::Migration
  def change
    create_table :seapig_router_sessions do |t|
      t.text :key
      t.timestamps null: false
    end
    add_index :seapig_router_sessions, :key, unique: true
  end
end
