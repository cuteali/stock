if @messages.present?
  json.result 0
  json.total_pages @messages.total_pages if params[:page_num]
  json.messages(@messages) do |message|
    json.message_id message.id
    json.title message.title
    json.info message.info
    json.is_new message.is_new_to_i
    json.image message.messageable_type == 'Product' ? Image.get_images(message.messageable).first.to_s : ''
    json.obj_id message.messageable.unique_id
    json.obj_type message.obj_type
    json.time message.created_at.strftime("%Y-%m-%d %H:%M:%S")
  end
else
  json.result 1
end
