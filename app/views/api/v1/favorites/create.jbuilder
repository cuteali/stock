if @favorite
  json.result 0
  json.errmsg '添加收藏成功'
  json.unique_id @favorite.unique_id
else
  json.result 1
  json.errmsg '添加收藏失败'
end