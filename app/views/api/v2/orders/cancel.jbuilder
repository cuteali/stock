if @order
  json.result 0
  json.errmsg '订单已取消'
else
  json.result 1
  json.errmsg '取消订单失败'
end
