class AddMinimumToProducts < ActiveRecord::Migration
  def change
  	add_column :products, :minimum, :integer, default: 1, after: :stock_num
  end
end
