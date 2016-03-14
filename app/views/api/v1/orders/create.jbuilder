if !@user.is_verified?
  json.result 4
  json.errmsg '用户未认证'
elsif @stock_num_result == 3
  json.result 3
  json.errmsg '产品库存不足'
elsif @order.present?
	json.result 0
else
  json.result 1
  json.errmsg '下单失败'
end