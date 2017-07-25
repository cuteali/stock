class ChangeOrderNoToOrders < ActiveRecord::Migration
  def change
    remove_index :orders, :order_no
  end
end
