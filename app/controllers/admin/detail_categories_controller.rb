class Admin::DetailCategoriesController < Admin::BaseController
  include Admin::CategoryHelper

  before_action :set_detail_category, only: [:edit, :update, :destroy, :stick_top]
  
  def index
    @q = DetailCategory.ransack(params[:q])
    @detail_categories = @q.result.sorted.page(params[:page])
    if params[:q]
      @category_id = params[:q][:category_id_eq]
      @sub_category_id = params[:q][:sub_category_id_eq]
    end
  end

  def new
    @detail_category = DetailCategory.new(sort: DetailCategory.init_sort)
  end

  def edit
  end

  def update
    if @detail_category.update(category_params)
        return redirect_to session[:return_to] if session[:return_to]
        redirect_to admin_detail_categories_path
      else
        render 'edit' 
      end
  end

  def destroy
    @detail_category.destroy
    redirect_to admin_detail_categories_path
  end

  def create
    @detail_category = DetailCategory.new(category_params)
    @detail_category.unique_id = SecureRandom.urlsafe_base64
    if @detail_category.save
      redirect_to admin_detail_categories_path
    else
      render 'new'
    end
  end

  def stick_top
    @detail_category.update(sort: DetailCategory.init_sort)
    redirect_to :back, notice: '操作成功'
  end

  def select_category
    options = SubCategory.where(category_id: params[:category_id]).order(:id)
    html = get_select_category_html(options, params[:id], params[:name], params[:first_option])
    render json: {html: html}
  end

  private 
    def set_detail_category
      @detail_category = DetailCategory.find(params[:id])
    end

    def category_params
      params.require(:detail_category).permit(:name, :sort, :desc, :category_id, :sub_category_id)
    end
end
