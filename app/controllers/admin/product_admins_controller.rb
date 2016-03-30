class Admin::ProductAdminsController < Admin::BaseController
  include Admin::CategoryHelper

  before_filter :find_product_admin, only: [ :edit, :update, :destroy ]

  def index
    @q = ProductAdmin.ransack(params[:q])
    @product_admins = @q.result.latest.page(params[:page])
  end

  def new
    @product_admin = ProductAdmin.new
    render :form
  end

  def create
    @product_admin = ProductAdmin.new(product_admin_params)
    if @product_admin.save
      @product_admin.product.add_or_cut_stock_num(@product_admin.product_num)
      redirect_to admin_product_admins_path
    else
      render :form
    end
  end

  def edit
    render :form
  end

  def update
    if @product_admin.update(product_admin_params)
      return redirect_to session[:return_to] if session[:return_to]
      redirect_to admin_product_admins_path
    else
      render :form
    end
  end

  def destroy
    @product_admin.product.add_or_cut_stock_num(-@product_admin.product_num)
    @product_admin.destroy
    redirect_to admin_product_admins_path
    # render inline: "<script>location.reload();</script>"
  end

  def select_category
    if params[:category_id]
      options = Object.const_get(params[:class_name]).where(category_id: params[:category_id]).order(:id)
    elsif params[:sub_category_id]
      options = Object.const_get(params[:class_name]).where(sub_category_id: params[:sub_category_id]).order(:id)
    elsif params[:detail_category_id]
      options = Object.const_get(params[:class_name]).where(detail_category_id: params[:detail_category_id]).order(:id)
    end
    html = get_select_category_html(options, params[:id], params[:name], params[:first_option])
    render json: {html: html}
  end

  private
    def find_product_admin
      @product_admin = ProductAdmin.find(params[:id])
    end

    def product_admin_params
      params.require(:product_admin).permit(:product_id, :product_name, :product_num, :stock_business, :stock_price, :stock_time)
    end
end
