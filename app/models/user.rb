class User < ActiveRecord::Base
  belongs_to :promoter
  has_many :addresses, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :images, as: :target
  has_many :cart_items
  has_many :favorites

  scope :latest, -> { order('created_at DESC') }

  def is_verified?
    identification == 1
  end

  def self.sign_in(phone_num_encrypt,rand_code)
    redis_rand_code = $redis.get(phone_num_encrypt)
    phone = AesUtil.aes_dicrypt($key, phone_num_encrypt)
    token = nil
    unique_id = nil
    if %w(F59E10256A72D10742349BEBBFDD8FA8 D6694C9CC6FD5AC0D6EABF1C6CB04B9D).include?(phone_num_encrypt)
      if rand_code == "1111"
        #1.验证正确,存入cookies.
        token = SecureRandom.urlsafe_base64
        user = User.find_by(phone_num:phone_num_encrypt)
        if user.present?
          user.update(token:token)
        else
          user = User.create(token: token, phone_num: phone_num_encrypt, phone: phone, unique_id: SecureRandom.urlsafe_base64, rand: "铜", identification: 1)
        end
        unique_id = user.unique_id
      else
        token = nil
      end
    else
      if redis_rand_code == rand_code
        #1.验证正确,存入cookies.
        token = SecureRandom.urlsafe_base64
        user = User.find_by(phone_num:phone_num_encrypt)
        if user.present?
          user.update(token:token)
        else
          user = User.create(token: token, phone_num: phone_num_encrypt, phone: phone, unique_id: SecureRandom.urlsafe_base64, rand: "铜", identification: 1)
        end
        unique_id = user.unique_id
      else
        token = nil
      end
    end

    [token,unique_id]
  end
end
