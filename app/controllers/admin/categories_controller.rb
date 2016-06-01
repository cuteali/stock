class Admin::CategoriesController < Admin::BaseController

  before_action :set_category, only: [:edit, :update, :destroy, :stick_top, :export_product]
  before_filter :authenticate_member!
  after_action :verify_authorized, only: :destroy
  
  def index
    @categories = Category.sorted.page(params[:page])
    respond_to do |format|
      format.html
      format.xls {
                send_data(ExportXls.export_excel,
                :type => "text/excel;charset=utf-8; header=present",
                :filename => Time.now.to_s(:db).to_s.gsub(/[\s|\t|\:]/,'_') + rand(99999).to_s + ".xls")
              }
    end
  end

  def new
    @category = Category.new(sort: Category.init_sort)
  end

  def edit
  end

  def update
    image_params = params[:category][:image]
    if @category.update(category_params)
      ImageUtil.image_upload(image_params,"Category",@category.id)
      return redirect_to session[:return_to] if session[:return_to]
      redirect_to admin_categories_path
    else
      render 'edit' 
    end
  end

  def destroy
    authorize @category
    @category.destroy
    redirect_to :back
  end

  def create
    image_params = params[:category][:image]
    @category = Category.new(category_params)
    @category.unique_id = SecureRandom.urlsafe_base64
    if @category.save
      ImageUtil.image_upload(image_params,"Category",@category.id)
      redirect_to admin_categories_path
    else
      render 'new'
    end
  end

  def stick_top
    @category.update(sort: Category.init_sort)
    redirect_to :back, notice: '操作成功'
  end

  def export_product
    respond_to do |format|
      format.xls {
                send_data(ExportXls.export_product_excel(@category),
                :type => "text/excel;charset=utf-8; header=present",
                :filename => Time.now.to_s(:db).to_s.gsub(/[\s|\t|\:]/,'_') + rand(99999).to_s + ".xls")
              }
    end
  end

  private 
    def set_category
      @category = Category.find(params[:id])
    end

    def category_params
      params.require(:category).permit(:name, :sort, :desc)
    end
end
