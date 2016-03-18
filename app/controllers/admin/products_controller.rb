class Admin::ProductsController < Admin::BaseController
  include Admin::CategoryHelper

  before_action :set_product, only: [:edit, :update, :destroy, :show, :image, :stick_top]
  
  def index
    @q = Product.ransack(params[:q])
    @products = @q.result.sorted.page(params[:page]).per(20)
    if params[:q]
      @category_id = params[:q][:category_id_eq]
      @sub_category_id = params[:q][:sub_category_id_eq]
      @detail_category_id = params[:q][:detail_category_id_eq]
    end
  end

  def new
    @product = Product.new(sort: Product.init_sort)
  end

  def edit
  end

  def update
    image_params = params[:product][:image]
    if @product.update(product_params)
        ImageUtil.image_upload(image_params, "Product", @product.id)
        return redirect_to session[:return_to] if session[:return_to]
        redirect_to admin_products_path
      else
        render 'edit' 
      end
  end

  def destroy
    @product.destroy
    redirect_to admin_products_path
  end

  def create
    @product = Product.new(product_params)
    @product.unique_id = SecureRandom.urlsafe_base64
    image_params = params[:product][:image]
    if @product.save
      ImageUtil.image_upload(image_params, "Product", @product.id)
      # redirect_to admin_products_path
      redirect_to :back, notice: '操作成功'
    else
      render 'new'
    end
  end

  def select_category
    options = Object.const_get(params[:class_name]).where(category_id: params[:category_id]).order(:id)
    html = get_select_category_html(options, params[:id], params[:name], params[:first_option])
    render json: {html: html}
  end

  def delete_image
    image = Image.find(params[:id])
    if image.delete
      image.image.file.delete
      redirect_to image_admin_product_path(params[:product_id])
    end
  end

  def image
  end

  def stick_top
    @product.update(sort: Product.init_sort)
    redirect_to :back, notice: '操作成功'
  end

  private
    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      params.require(:product).permit(:name, :sort, :desc, :info, :state, :unit_id, :stock_num, :price, :old_price, :category_id, :sub_category_id, :detail_category_id, :hot_category_id, :sale_count, :spec, :unit_price, :origin, :remark)
    end
end
