class Message < ActiveRecord::Base
  belongs_to :user
  belongs_to :messageable, polymorphic: true

  enum status: [ :normal, :deleted ]
  enum is_new: [ :unread, :read ]

  scope :latest, -> { order('created_at DESC') }
  scope :by_page, -> (page_num) { page(page_num) if page_num }
  scope :broadcast, -> { where("user_id is ?", nil) }

  def push_message
    User.client_users.each do |u|
      if u.client_id
        message = u.messages.create(messageable_id: messageable_id, messageable_type: messageable_type, title: title, info: info)
        message.jpush_push_message(alert: message.info, client_id: u.client_id)
      end
    end
  end

  def is_new_to_i
    unread? ? '0' : '1'
  end

  def obj_type
    case messageable_type
    when 'Product' then '0'
    when 'Order' then '1'
    end
  end

  def jpush_push_message(options)
    jpush = JPush::Client.new(ENV['jpush_app_key'], ENV['jpush_master_secret'])

    pusher = jpush.pusher

    notification = JPush::Push::Notification.new.
    set_android(
      alert: options[:alert] || info,
      title: title.blank? ? '要货啦' : title,
      extras: {obj_id: messageable.try(:unique_id), obj_type: obj_type, message_id: id}
    ).set_ios(
      alert: options[:alert] || info,
      sound: 'default',
      badge: 1,
      available: true,
      extras: {obj_id: messageable.try(:unique_id), obj_type: obj_type, message_id: id}
    )

    if options[:client_id]
      audience = JPush::Push::Audience.new.set_registration_id(options[:client_id])
    end

    push_payload = JPush::Push::PushPayload.new(
      platform: 'all',
      audience: audience || 'all',
      notification: notification
    ).set_message(
      options[:alert] || info,
      title: title.blank? ? '要货啦' : title
    ).set_options(
      apns_production: false
    )
    ret = pusher.push(push_payload) rescue nil
    Rails.logger.info "============#{ret}============"
  end
end
