class CreateProductAdmins < ActiveRecord::Migration
  def change
    create_table :product_admins do |t|
      t.integer  :product_id
      t.string   :product_name
      t.integer  :product_num
      t.string   :stock_business
      t.decimal  :stock_price, default: 0.00, null: true, precision: 12, scale: 2
      t.datetime :stock_time

      t.timestamps null: false
    end

    add_index :product_admins, :product_id
  end
end
