require 'net/http'
require 'uri'
module Sms
  def self.send_sms(mobile_encrypts, text, rand=nil)
    mobiles = mobile_encrypts.map {|mobile_encrypt| AesUtil.aes_dicrypt($key,mobile_encrypt) }
    AppLog.info("mobiles: #{mobiles}")
    params = {}
    #修改为您的apikey.可在官网（http://www.yuanpian.com)登录后用户中心首页看到
    apikey = '7c5ab5d6099fdaa4424fd0ad8ca29388'
    #修改为您要发送的手机号码，多个号码用逗号隔开
    # mobile = '18301849268'

    #指定模板发送接口HTTP地址
    send_sms_uri = URI.parse('https://sms.yunpian.com/v1/sms/send.json')

    params['apikey'] = apikey

    params['mobile'] = mobiles.join(',')
    params['text'] = text

    response = Net::HTTP.post_form(send_sms_uri,params)
    response = JSON.parse(response.body)
    AppLog.info("response:  #{response}")
    if response["code"] == 0
      if rand
        mobile_encrypts.each do |mobile_encrypt|
          $redis.set(mobile_encrypt,rand)
          $redis.expire(mobile_encrypt,1800)
          AppLog.info("#{$redis.get(mobile_encrypt)}")
        end
      end
      return "success"
    else
      return "error"
    end
  end

  def self.rand_code
    newpass = ""
    1.upto(4){ |i| newpass << rand(10).to_s}
    return newpass
  end

  def self.app_error_msg
    mobile_encrypts = User.all.pluck(:phone_num)
    text = "【要货啦】您好，要货啦APP苹果版 出现暂时性故障，安卓版新版本现在可以正常使用。如需订货请拨打客服电话400-0050-383转1！"
    Sms.send_sms(mobile_encrypts, text)
  end

  def self.app_ios_msg
    mobile_encrypts = User.where(client_type: 'ios').pluck(:phone_num)
    text = "【要货啦】要货啦苹果最新版已经上架，请您在App Store中搜索要货啦，进行更新。如有问题请联系客服，电话：400-0050-383"
    Sms.send_sms(mobile_encrypts, text)
  end
end
