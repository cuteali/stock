if @token.blank?
  json.result 1
  if @user.blank?
    json.errmsg '手机号不正确'
  elsif !@is_rand_code
    json.errmsg '验证码不正确'
  else
    json.errmsg '登录失败'
  end
  json.token ""
else
  json.result 0
  json.token @token.to_s
  json.send_price 0
  json.delivery_price @delivery_price
  json.phone_num '400-0050-383'
  json.promoter_no @user.promoter.try(:promoter_no).to_s
end
