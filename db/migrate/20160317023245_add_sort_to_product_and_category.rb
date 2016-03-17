class AddSortToProductAndCategory < ActiveRecord::Migration
  def change
    add_column :products, :sort, :integer, null: false, default: 1, after: :name
    add_column :categories, :sort, :integer, null: false, default: 1, after: :name
    add_column :sub_categories, :sort, :integer, null: false, default: 1, after: :name
    add_column :detail_categories, :sort, :integer, null: false, default: 1, after: :name

    add_index :products, :sort
    add_index :categories, :sort
    add_index :sub_categories, :sort
    add_index :detail_categories, :sort
  end
end
