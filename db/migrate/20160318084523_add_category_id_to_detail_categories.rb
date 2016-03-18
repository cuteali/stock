class AddCategoryIdToDetailCategories < ActiveRecord::Migration
  def change
    add_column :detail_categories, :category_id, :integer, after: :sort
    add_index :detail_categories, :category_id
  end
end
