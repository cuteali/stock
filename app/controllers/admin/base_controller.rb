class Admin::BaseController < ApplicationController
  include MonthFilteringForBase
  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  # http_basic_authenticate_with name: "tsingcloud@tsingcloud.cc", password: "hiyaohuola666"
  before_filter :filter_current_member

  def filter_current_member
    redirect_to admin_path, alert: '您没有权限进行此操作！请登录' and return false unless current_member.is_a?(Member)
  end


  private

    def user_not_authorized
      flash[:warning] = "你未被授权执行该操作。"
      redirect_to(request.referrer || root_path)
    end
end
