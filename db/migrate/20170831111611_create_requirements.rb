class CreateRequirements < ActiveRecord::Migration[5.0]
  def change
    create_table :requirements do |t|
      t.uuid :uuid, unique: true
      t.jsonb :description
      

      t.timestamps
    end
  end
end
