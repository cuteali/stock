class AddBarCodeToProduct < ActiveRecord::Migration
  def change
    add_column :products, :bar_code, :string, after: :name
  end
end
