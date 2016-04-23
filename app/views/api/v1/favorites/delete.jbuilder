if @favorite
  json.result 0
  json.errmsg '删除收藏成功'
else
  json.result 1
  json.errmsg '删除收藏失败'
end
