class Admin::BaseController < ApplicationController
  include MonthFilteringForBase
  
  http_basic_authenticate_with name: "stock", password: "hiyaohuola666"
  layout 'admin/layouts/application'
end
