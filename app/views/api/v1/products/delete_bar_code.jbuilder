if @result
  json.result 0
  json.errmsg '条形码删除成功'
  json.bar_codes @product.bar_codes.pluck(:bar_code_no).join(',')
else
  json.result 1
  json.errmsg '条形码删除失败'
end
