class ChangeOrderNoToOrders < ActiveRecord::Migration
  def change
    add_index :orders, :order_no, unique: true
  end
end
