class AddRequirementIdToTask < ActiveRecord::Migration[5.0]
  def change
    add_column :tasks, :requirement_id, :integer
  end
end
