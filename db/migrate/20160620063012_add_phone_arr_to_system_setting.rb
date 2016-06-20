class AddPhoneArrToSystemSetting < ActiveRecord::Migration
  def change
    add_column :system_settings, :phone_arr, :string, after: :delivery_price
  end
end
