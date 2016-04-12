class CreateValues < ActiveRecord::Migration
  def change
    create_table :values do |t|
      t.integer :property_id
      t.text :value

      t.timestamps null: false
    end
  end
end
