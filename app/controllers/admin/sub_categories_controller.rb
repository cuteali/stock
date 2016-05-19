class Admin::SubCategoriesController < Admin::BaseController

  before_action :set_sub_category, only: [:edit, :update, :destroy, :stick_top]
  before_filter :authenticate_member!
  after_action :verify_authorized, only: :destroy
  
  def index
    @q = SubCategory.ransack(params[:q])
    @sub_categories = @q.result.sorted.page(params[:page])
  end

  def new
    @sub_category = SubCategory.new(sort: SubCategory.init_sort)
  end

  def edit
  end

  def update
    if @sub_category.update(category_params)
        return redirect_to session[:return_to] if session[:return_to]
        redirect_to admin_sub_categories_path
      else
        render 'edit' 
      end
  end

  def destroy
    authorize @sub_category
    @sub_category.destroy
    redirect_to :back
  end

  def create
    @sub_category = SubCategory.new(category_params)
    @sub_category.unique_id = SecureRandom.urlsafe_base64
    if @sub_category.save
      redirect_to admin_sub_categories_path
    else
      render 'new'
    end
  end

  def stick_top
    @sub_category.update(sort: SubCategory.init_sort)
    redirect_to :back, notice: '操作成功'
  end

  private 
    def set_sub_category
      @sub_category = SubCategory.find(params[:id])
    end

    def category_params
      params.require(:sub_category).permit(:name, :sort, :desc, :category_id)
    end
end
