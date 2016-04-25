if @favorites
  json.result 0
  json.errmsg '清空收藏成功'
else
  json.result 1
  json.errmsg '清空收藏失败'
end
