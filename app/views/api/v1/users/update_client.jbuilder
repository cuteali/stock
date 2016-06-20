if @result
  json.result 0
  json.errmsg '设备号更新成功'
else
  json.result 1
  json.errmsg '设备号更新失败'
end