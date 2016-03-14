if @info == "success"
  json.result 0
else
  json.result 1
  json.errmsg '删除地址失败'
end