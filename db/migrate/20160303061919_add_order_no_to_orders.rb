class AddOrderNoToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :order_no, :string, after: :state
    add_index :orders, :order_no
  end
end
