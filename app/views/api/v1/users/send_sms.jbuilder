if @info == "error"
  json.result 1
  json.errmsg '验证码发送失败'
else
  json.result 0
end
