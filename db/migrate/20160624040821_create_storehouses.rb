class CreateStorehouses < ActiveRecord::Migration
  def change
    create_table :storehouses do |t|
      t.string :name
      t.string :detail

      t.timestamps null: false
    end
    add_column :orders, :storehouse_id, :integer
    add_index :orders, :storehouse_id
  end
end
