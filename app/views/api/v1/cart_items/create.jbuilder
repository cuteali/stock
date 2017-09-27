# if @is_restricting
#   json.result 1
#   json.errmsg '产品已达每日限购数量'
# elsif @info == 'success'
#   json.result 0
#   json.unique_id @cart_item.try(:unique_id).to_s
#   json.cart_total_num @cart_item_total_num
# else
#   json.result 1
#   if @product.blank?
#     json.errmsg '添加失败，产品未找到'
#   else
#     json.errmsg '添加购物车失败'
#   end
# end
json.result 1
json.errmsg @errmsg
