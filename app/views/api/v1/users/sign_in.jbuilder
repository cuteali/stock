if @token.blank?
  json.result 1
  json.errmsg '登录失败，手机或验证码不正确'
  json.token ""
else
  json.result 0
  json.token @token.to_s
  json.send_price 0
  json.delivery_price @delivery_price
  json.phone_num '400-0050-383'
end
