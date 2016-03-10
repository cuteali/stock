class ServiceAgreementController < ApplicationController
  def index
  end

  def app_download
    redirect_to 'http://a.app.qq.com/o/simple.jsp?pkgname=com.android.yaohuola'
  end
end