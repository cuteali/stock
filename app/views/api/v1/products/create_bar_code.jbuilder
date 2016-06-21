if @bar_code.present?
  json.result 0
  json.errmsg '条形码上传成功'
  json.bar_codes @product.bar_codes.pluck(:bar_code_no).join(',')
else
  json.result 1
  json.errmsg '条形码上传失败'
end
