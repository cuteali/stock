class SystemSetting < ActiveRecord::Base

  def self.get_phone_arr
    SystemSetting.first.phone_arr.split(',').map{|phone| AesUtil.aes_encrypt($key, phone) }
  end
end
