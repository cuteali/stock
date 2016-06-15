class AddRemarksToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :remarks, :string
  end
end
