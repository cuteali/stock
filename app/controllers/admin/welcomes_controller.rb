class Admin::WelcomesController < Admin::BaseController
  skip_before_filter :filter_current_member

  def index
    if current_member && current_member.is_a?(Member)
      if current_member.spreader?
        redirect_to admin_orders_url
      else
        redirect_to admin_products_url
      end
    elsif request.referrer =~ /admin/i || request.referrer =~ /members/i
      redirect_to admin_url
    else
      redirect_to app_download_service_agreement_index_url
    end
  end
end
