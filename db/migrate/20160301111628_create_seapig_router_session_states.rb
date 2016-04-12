class CreateSeapigRouterSessionStates < ActiveRecord::Migration
  def change
    create_table :seapig_router_session_states do |t|
      t.integer :seapig_router_session_id
      t.integer :state_id
      t.jsonb :state

      t.timestamps null: false
    end
    add_index :seapig_router_session_states, [:seapig_router_session_id,:state_id], unique: true, name: "seapig_router_session_states_index_1"

  end
end
