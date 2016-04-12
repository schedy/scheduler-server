class CreateWorkers < ActiveRecord::Migration
  def change
    create_table :workers do |t|
      t.text :name

      t.timestamps null: false
    end
  end
end
