class AddInfoToProducts < ActiveRecord::Migration
  def change
    add_column :products, :info, :string, after: :desc
  end
end
