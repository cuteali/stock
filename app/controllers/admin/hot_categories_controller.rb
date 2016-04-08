class Admin::HotCategoriesController < Admin::BaseController

  before_action :set_hot_category, only:[:edit, :update, :destroy]
  before_filter :authenticate_member!
  after_action :verify_authorized, only: :destroy
  
  def index
    @hot_categories = HotCategory.all
  end

  def new
    @hot_category = HotCategory.new
  end

  def create
    @hot_category = HotCategory.new(category_params)
    @hot_category.unique_id = SecureRandom.urlsafe_base64
    if @hot_category.save
      redirect_to admin_hot_categories_path
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @hot_category.update(category_params)
        return redirect_to session[:return_to] if session[:return_to]
        redirect_to admin_hot_categories_path
      else
        render 'edit' 
      end
  end

  def destroy
    authorize @hot_category
    @hot_category.destroy
    redirect_to admin_hot_categories_path
  end

  private 
    def set_hot_category
      @hot_category = HotCategory.find(params[:id])
    end

    def category_params
      params.require(:hot_category).permit(:name,:desc)
    end
end
