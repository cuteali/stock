class ChangeColumnsOrderMoneyToOrders < ActiveRecord::Migration
  def change
    change_column :orders, :order_money, :decimal, default: 0.00, null: true, precision: 12, scale: 2
    change_column :products, :price, :decimal, default: 0.00, null: true, precision: 12, scale: 2
    change_column :products, :old_price, :decimal, default: 0.00, null: true, precision: 12, scale: 2
  end
end
