# This migration comes from seapig_engine (originally 20161231183822)
class AddTokenToSeapigSessions < ActiveRecord::Migration
	def change
		add_column :seapig_router_sessions, :token, :text
		add_index :seapig_router_sessions, :token, unique: true, name: "seapig_router_sessions_token_index"
		add_index :seapig_router_sessions, [:key,:token], unique: true, name: "seapig_router_sessions_key_token_index"
	end
end
