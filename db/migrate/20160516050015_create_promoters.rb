class CreatePromoters < ActiveRecord::Migration
  def change
    create_table :promoters do |t|
      t.string :name
      t.string :phone
      t.string :id_card
      t.integer :sex, limit: 1, null: false, default: 0
      t.string :material

      t.timestamps null: false
    end
    add_index :promoters, :name
  end
end
