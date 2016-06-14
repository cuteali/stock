class CreateSystemSettings < ActiveRecord::Migration
  def change
    create_table :system_settings do |t|
      t.decimal  :delivery_price, default: 0.00, null: true, precision: 12, scale: 2

      t.timestamps null: false
    end
  end
end
