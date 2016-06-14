class AddStatusToOrdersProduct < ActiveRecord::Migration
  def change
    add_column :orders_products, :status, :integer, limit: 1, null: false, default: 0, after: :product_price
  end
end
