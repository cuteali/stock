class AddColumnPhoneToUsers < ActiveRecord::Migration
  def change
    add_column :users, :phone, :string, after: :phone_num
    add_index :users,:phone
  end
end
