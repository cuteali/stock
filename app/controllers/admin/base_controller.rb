class Admin::BaseController < ApplicationController
  include MonthFilteringForBase
  
  # http_basic_authenticate_with name: "tsingcloud@tsingcloud.cc", password: "hiyaohuola666"
  before_filter :filter_current_member

  def filter_current_member
    redirect_to admin_path, alert: '您没有权限进行此操作！请登录' and return false unless current_member.is_a?(Member)
  end
end
