if @info == "success"
  json.result 0
else
  json.result 1
  json.errmsg '清空购物车失败，请核对参数'
end