if @info == 'success'
  json.result 0
  json.address do
    json.unique_id @address.id.to_s
    json.receive_name @address.receive_name.to_s
    json.receive_phone @address.receive_phone.to_s
    json.area @address.area.to_s
    json.detail @address.detail.to_s
    json.default @address.default.to_s
  end
else
  json.result 1
  json.errmsg '更新地址失败'
end