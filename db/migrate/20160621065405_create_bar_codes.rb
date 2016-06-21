class CreateBarCodes < ActiveRecord::Migration
  def change
    create_table :bar_codes do |t|
      t.references :product
      t.string :bar_code_no

      t.timestamps null: false
    end
    add_index :bar_codes, :product_id
  end
end
