class Admin::DetailCategoriesController < Admin::BaseController
  include Admin::CategoryHelper

  before_action :set_detail_category, only: [:edit, :update, :destroy, :stick_top]
  before_filter :authenticate_member!
  after_action :verify_authorized, only: :destroy
  
  def index
    @q = DetailCategory.ransack(params[:q])
    @detail_categories = @q.result.sorted.page(params[:page])
  end

  def new
    @detail_category = DetailCategory.new(sort: DetailCategory.init_sort)
  end

  def edit
  end

  def update
    image_params = params[:detail_category][:image]
    if @detail_category.update(category_params)
        ImageUtil.image_upload(image_params,"DetailCategory",@detail_category.id)
        return redirect_to session[:return_to] if session[:return_to]
        redirect_to admin_detail_categories_path
      else
        render 'edit' 
      end
  end

  def destroy
    authorize @detail_category
    @detail_category.destroy
    redirect_to :back
  end

  def create
    image_params = params[:detail_category][:image]
    @detail_category = DetailCategory.new(category_params)
    @detail_category.unique_id = SecureRandom.urlsafe_base64
    if @detail_category.save
      ImageUtil.image_upload(image_params,"DetailCategory",@detail_category.id)
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
