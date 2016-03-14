if @token.blank?
  json.result 1
  json.token ""
else
  json.result 0
  json.token @token.to_s
  json.send_price 0
  json.phone_num '400-0050-383'
end
