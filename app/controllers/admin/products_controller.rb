class Admin::ProductsController < Admin::BaseController
  include Admin::CategoryHelper

  before_action :set_product, only: [:edit, :update, :destroy, :show, :image, :stick_top, :statistics, :new_stock, :create_stock]
  before_filter :authenticate_member!
  after_action :verify_authorized, only: :destroy
  
  def index
    @q = Product.ransack(params[:q])
    @products = @q.result.sorted.page(params[:page])
  end

  def new
    @product = Product.new(sort: Product.init_sort)
  end

  def edit
  end

  def update
    image_params = params[:product][:image]
    @product.update_orders_product_cost_price(product_params[:cost_price]) if product_params[:cost_price].present? && @product.cost_price != product_params[:cost_price].to_f
    if @product.update(product_params)
      CartItem.product_sold_off(@product.id) if product_params[:state] == '0'
      ImageUtil.image_upload(image_params, "Product", @product.id)
      @product.update_cart_items_num
      @product.save_bar_codes(params[:bar_codes])
      return redirect_to session[:return_to] if session[:return_to]
      redirect_to admin_products_path
    else
      render 'edit' 
    end
  end

  def destroy
    authorize @product
    @product.destroy
    redirect_to :back
  end

  def create
    @product = Product.new(product_params)
    @product.unique_id = SecureRandom.urlsafe_base64
    image_params = params[:product][:image]
    if @product.save
      ImageUtil.image_upload(image_params, "Product", @product.id)
      @product.update_cart_items_num
      @product.save_bar_codes(params[:bar_codes])
      redirect_to admin_products_path, notice: '操作成功'
    else
      render 'new'
    end
  end

  def select_category
    if params[:category_id]
      options = Object.const_get(params[:class_name]).where(category_id: params[:category_id]).order(:id)
    elsif params[:sub_category_id]
      options = Object.const_get(params[:class_name]).where(sub_category_id: params[:sub_category_id]).order(:id)
    elsif params[:detail_category_id]
      options = Object.const_get(params[:class_name]).where(detail_category_id: params[:detail_category_id]).sorted
    end
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

  def upload_csv
    uploaded_file = params[:file]
    return redirect_to :back, alert: "请导入格式为.csv的文件。" if uploaded_file.blank?

    tempfile = uploaded_file.tempfile
    return redirect_to :back, alert: "请导入格式为.csv的文件。" if uploaded_file.original_filename !~ /\.csv\z/i
    return redirect_to :back, alert: "上传文件不能大于1M，请重新上传。" if tempfile.size > 1024 ** 2

    file_name = copy_tempfile(tempfile)
    result = Product.validate_and_import(file_name)

    respond_to do |format|
      if result.is_a?(Hash) # 产品导入失败，数据格式不正确
        format.json { render json: result }
        format.html { redirect_to :back, alert: result[:message] }
      else
        format.json { flash.notice = "文件上传成功，请于10分钟后查看数据导入情况"; render json: {} }
        format.html { redirect_to :back, notice: "文件上传成功，请于10分钟后查看数据导入情况"  }
      end
    end
  end

  def statistics
    @orders_products = @product.orders_products
    @select_time = true if params[:start_time].present? && params[:end_time].present?
    @date = params[:created_date].present? ? params[:created_date] : "one_days"
    @today = Date.today
    @categories, @series, @start_time, @end_time, @count, @min_tick, @total = OrdersProduct.chart_pro_data(@orders_products, @date, @today, @select_time, params)
    @chart = OrdersProduct.chart_base_line(@categories, @series, @min_tick) if @categories.present?
    @orders_products_stats = OrdersProduct.get_product_stats(@total, @start_time, @end_time)
  end

  def new_stock
    @product_admin = @product.product_admins.new
  end

  def create_stock
    @product_admin = @product.product_admins.new(product_admin_params)
    if @product_admin.save
      @product_admin.product.add_or_cut_stock_num(@product_admin.product_num)
      redirect_to :back, notice: '进货成功'
    else
      redirect_to :back, notice: '进货失败'
    end
  end

  private
    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      params.require(:product).permit(:name, :sort, :desc, :info, :state, :unit_id, :stock_num, :restricting_num, :price, :old_price, :category_id, :sub_category_id, :detail_category_id, :hot_category_id, :sale_count, :spec, :unit_price, :origin, :remark, :cost_price)
    end

    def product_admin_params
      params.require(:product_admin).permit(:product_id, :product_name, :product_num, :stock_business, :stock_price, :stock_time)
    end

    def copy_tempfile(tempfile)
      dir = "#{Rails.root}/public/uploads/tmp/product_csv"
      file_name = "#{dir}/#{Time.now.to_s(:number)}.csv"
      FileUtils.mkdir_p dir
      FileUtils.copy tempfile.path, file_name
      file_name
    end
end
