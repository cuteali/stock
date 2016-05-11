class Admin::ProductsController < Admin::BaseController
  include Admin::CategoryHelper

  before_action :set_product, only: [:edit, :update, :destroy, :show, :image, :stick_top]
  before_filter :authenticate_member!
  after_action :verify_authorized, only: :destroy
  
  def index
    @q = Product.ransack(params[:q])
    @products = @q.result.sorted.page(params[:page])
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
      # redirect_to admin_products_path
      redirect_to :back, notice: '操作成功'
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

  private
    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      params.require(:product).permit(:name, :sort, :desc, :info, :state, :unit_id, :stock_num, :price, :old_price, :category_id, :sub_category_id, :detail_category_id, :hot_category_id, :sale_count, :spec, :unit_price, :origin, :remark)
    end

    def copy_tempfile(tempfile)
      dir = "#{Rails.root}/public/uploads/tmp/product_csv"
      file_name = "#{dir}/#{Time.now.to_s(:number)}.csv"
      FileUtils.mkdir_p dir
      FileUtils.copy tempfile.path, file_name
      file_name
    end
end
