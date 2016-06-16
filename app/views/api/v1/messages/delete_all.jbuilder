if !@messages.include?(false)
  json.result 0
else
  json.result 1
  json.errmsg '清空消息失败'
end
