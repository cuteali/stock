if !@user.is_verified?
  json.result 4
  json.errmsg '用户未认证'
elsif @is_restricting
  json.result 1
  json.errmsg '产品已达每日限购数量'
elsif @is_send_out
  json.result 1
  json.errmsg '您好，冷饮5件以上起送！'
elsif !@is_sending_price
  json.result 1
  json.errmsg "您好，订单满#{@delivery_price}元起送！"
elsif @not_enough_products.present?
  json.result 3
  json.errmsg "产品：#{@not_enough_products.join(',')} 库存不足"
elsif @sold_off_products.present?
  json.result 1
  json.errmsg "产品：#{@sold_off_products.join(',')} 已下架"
elsif @order.present?
	json.result 0
else
  json.result 1
  json.errmsg '下单失败'
end