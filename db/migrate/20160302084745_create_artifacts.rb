class CreateArtifacts < ActiveRecord::Migration
  def change
    create_table :artifacts do |t|
      t.integer :task_id
      t.text :name
      t.text :mimetype
      t.binary :data

      t.timestamps null: false
    end
  end
end
