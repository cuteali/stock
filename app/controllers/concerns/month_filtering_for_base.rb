module MonthFilteringForBase
  extend ActiveSupport::Concern

  included do
    before_filter :session_referrer, only: [:edit]
  end

  def session_referrer
    if request.referrer =~ /admin/i
      session[:return_to] = request.referrer
    end
  end
end
