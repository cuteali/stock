class AddProductPriceToOrdersProducts < ActiveRecord::Migration
  def change
    add_column :orders_products, :product_price, :decimal, default: 0.00, null: true, precision: 12, scale: 2, after: :product_num
  end
end
