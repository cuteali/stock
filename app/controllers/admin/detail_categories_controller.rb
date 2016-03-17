class Admin::DetailCategoriesController < Admin::BaseController

  before_action :set_detail_category, only: [:edit, :update, :destroy, :stick_top]
  
  def index
    @categories = DetailCategory.sorted
  end

  def new
    @category = DetailCategory.new(sort: DetailCategory.init_sort)
  end

  def edit
  end

  def update
    if @category.update(category_params)
        redirect_to admin_detail_categories_path
      else
        render 'edit' 
      end
  end

  def destroy
    @category.destroy
    redirect_to admin_detail_categories_path
  end

  def create
    @category = DetailCategory.new(category_params)
    @category.unique_id = SecureRandom.urlsafe_base64
    if @category.save
      redirect_to admin_detail_categories_path
    else
      render 'new'
    end
  end

  def stick_top
    @category.update(sort: DetailCategory.init_sort)
    redirect_to :back, notice: '操作成功'
  end

  private 
    def set_detail_category
      @category = DetailCategory.find(params[:id])
    end

    def category_params
      params.require(:detail_category).permit(:name, :sort, :desc, :sub_category_id)
    end
end
