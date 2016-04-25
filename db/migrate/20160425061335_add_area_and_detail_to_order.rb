class AddAreaAndDetailToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :area, :string, after: :receive_name
    add_column :orders, :detail, :string, after: :area
  end
end
