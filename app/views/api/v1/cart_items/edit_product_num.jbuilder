if @cart_item.save
  json.result 0
else
  json.result 1
  json.errmsg '修改产品数量失败'
end