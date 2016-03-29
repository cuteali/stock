class RemoveColumnProductsToOrders < ActiveRecord::Migration
  def up
    remove_column :orders, :products
  end

  def down
    add_column :orders, :products, :string, after: :complete_time
  end
end
