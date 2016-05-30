class AddRestrictingNumToProduct < ActiveRecord::Migration
  def change
    add_column :products, :restricting_num, :integer, after: :stock_num
    add_column :orders_products, :user_id, :integer, after: :id
    add_index :orders_products, :user_id
  end
end
