class RemoveColumnsBarCodeToProduct < ActiveRecord::Migration
  def up
    remove_column :products, :bar_code
  end

  def down
    add_column :products, :bar_code, :string, after: :name
  end
end
