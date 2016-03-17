class Admin::SubCategoriesController < Admin::BaseController

  before_action :set_sub_category, only: [:edit, :update, :destroy, :stick_top]
  
  def index
    @categories = SubCategory.sorted
  end

  def new
    @category = SubCategory.new(sort: SubCategory.init_sort)
  end

  def edit
  end

  def update
    if @category.update(category_params)
        redirect_to admin_sub_categories_path
      else
        render 'edit' 
      end
  end

  def destroy
    @category.destroy
    redirect_to admin_sub_categories_path
  end

  def create
    @category = SubCategory.new(category_params)
    @category.unique_id = SecureRandom.urlsafe_base64
    if @category.save
      redirect_to admin_sub_categories_path
    else
      render 'new'
    end
  end

  def stick_top
    @category.update(sort: SubCategory.init_sort)
    redirect_to :back, notice: '操作成功'
  end

  private 
    def set_sub_category
      @category = SubCategory.find(params[:id])
    end

    def category_params
      params.require(:sub_category).permit(:name, :sort, :desc, :category_id)
    end
end
