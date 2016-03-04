class AddCategoryIdToProducts < ActiveRecord::Migration
  def change
    add_column :products, :category_id, :integer, after: :old_price
    add_index :products,:category_id
  end
end
