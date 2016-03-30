class Admin::OrderStatController < Admin::BaseController
  def index
    @q = Order.ransack(params[:q])
    @orders = @q.result.latest.page(params[:page])
  end
end
