class CreateMergeOrdersOrders < ActiveRecord::Migration
  def change
    create_table :merge_orders_orders do |t|
    	t.references :merge_order
      t.references :order

      t.timestamps null: false
    end
    add_index :merge_orders_orders, :merge_order_id
    add_index :merge_orders_orders, :order_id
  end
end
