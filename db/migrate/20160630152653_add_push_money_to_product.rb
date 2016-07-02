class AddPushMoneyToProduct < ActiveRecord::Migration
  def change
  	add_column :products, :push_money, :decimal, default: 0.00, null: true, precision: 12, scale: 2, after: :cost_price
  	add_column :orders_products, :push_money, :decimal, default: 0.00, null: true, precision: 12, scale: 2, after: :cost_price
  end
end
