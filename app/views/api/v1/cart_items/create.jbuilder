if @info == 'success'
  json.result 0
else
  json.result 1
  if @product.blank?
    json.errmsg '添加失败，产品未找到'
  else
    json.errmsg '添加购物车失败'
  end
end