class CreateMergeOrdersProducts < ActiveRecord::Migration
  def change
    create_table :merge_orders_products do |t|
      t.references :merge_order
      t.references :product
      t.integer    :product_num

      t.timestamps null: false
    end
    add_index :merge_orders_products, :merge_order_id
    add_index :merge_orders_products, :product_id
  end
end
