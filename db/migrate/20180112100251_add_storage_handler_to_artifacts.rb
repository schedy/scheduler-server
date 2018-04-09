class AddStorageHandlerToArtifacts < ActiveRecord::Migration[5.0]
  def change
    add_column :artifacts, :size, :integer
    add_column :artifacts, :storage_handler, :text
    add_column :artifacts, :storage_handler_data, :jsonb
    add_column :artifacts, :external_url, :text

    execute "UPDATE artifacts SET size = length(data)"
    execute "ALTER TABLE artifacts ALTER COLUMN size SET NOT NULL"
  end
end
