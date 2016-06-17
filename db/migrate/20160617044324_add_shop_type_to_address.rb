class AddShopTypeToAddress < ActiveRecord::Migration
  def change
    add_column :addresses, :shop_type, :integer, limit: 1, after: :default
    add_column :orders, :deliveryman_id, :integer
    add_column :orders, :car_id, :integer
    add_index :orders, :deliveryman_id
    add_index :orders, :car_id
  end
end
