class AddSafeStockNumToProduct < ActiveRecord::Migration
  def change
    add_column :products, :safe_stock_num, :integer, after: :stock_num
  end
end
