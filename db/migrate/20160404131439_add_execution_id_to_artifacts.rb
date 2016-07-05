class AddExecutionIdToArtifacts < ActiveRecord::Migration
  def change
    add_column :artifacts, :execution_id, :integer
  end
end
