class AddCostPriceToProduct < ActiveRecord::Migration
  def change
    add_column :products, :cost_price, :decimal, default: 0.00, null: true, precision: 12, scale: 2, after: :old_price
    add_column :orders_products, :cost_price, :decimal, default: 0.00, null: true, precision: 12, scale: 2, after: :product_price
    add_column :orders, :total_cost_price, :decimal, default: 0.00, null: true, precision: 12, scale: 2, after: :order_money
  end
end
