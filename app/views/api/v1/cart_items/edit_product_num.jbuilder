# if @is_restricting
#   json.result 1
#   json.errmsg '产品已达每日限购数量'
# elsif @result
#   json.result 0
#   json.cart_total_num @cart_item_total_num
# else
#   json.result 1
#   json.errmsg '修改产品数量失败'
# end
json.result 1
json.errmsg @errmsg
