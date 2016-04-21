class Admin::CategoriesController < Admin::BaseController

  before_action :set_category, only: [:edit, :update, :destroy, :stick_top]
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
    if @category.update(category_params)
        return redirect_to session[:return_to] if session[:return_to]
        redirect_to admin_categories_path
      else
        render 'edit' 
      end
  end

  def destroy
    authorize @category
    @category.destroy
    redirect_to admin_categories_path
  end

  def create
    @category = Category.new(category_params)
    @category.unique_id = SecureRandom.urlsafe_base64
    if @category.save
      redirect_to admin_categories_path
    else
      render 'new'
    end
  end

  def stick_top
    @category.update(sort: Category.init_sort)
    redirect_to :back, notice: '操作成功'
  end

  private 
    def set_category
      @category = Category.find(params[:id])
    end

    def category_params
      params.require(:category).permit(:name, :sort, :desc)
    end
end
