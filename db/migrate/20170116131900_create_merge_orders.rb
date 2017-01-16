class CreateMergeOrders < ActiveRecord::Migration
  def change
    create_table :merge_orders do |t|
      t.string :merge_order_no
      t.string :unique_id
    	t.integer :state
      t.references :member, index: true, foreign_key: true

      t.timestamps null: false
    end
    add_index :merge_orders, :merge_order_no
  end
end
