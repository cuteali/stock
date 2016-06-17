class CreateDeliverymen < ActiveRecord::Migration
  def change
    create_table :deliverymen do |t|
      t.string :name
      t.string :phone

      t.timestamps null: false
    end
  end
end
