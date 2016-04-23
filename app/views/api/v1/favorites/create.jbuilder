if @favorite
  json.result 0
  json.errmsg '添加收藏成功'
else
  json.result 1
  json.errmsg '添加收藏失败'
end