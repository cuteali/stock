if @info == "success"
  json.result 0
  json.cart_total_num @cart_item_total_num
else
  json.result 1
  json.errmsg '清空购物车失败，请核对参数'
end