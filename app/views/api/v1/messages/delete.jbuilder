if @message
  json.result 0
else
  json.result 1
  json.errmsg '删除消息失败'
end
