class Admin::StorehousesController < Admin::BaseController
  before_action :set_storehouse,only:[:edit,:update,:destroy]
  before_filter :authenticate_member!

  def index
    @storehouses = Storehouse.page(params[:page])
  end

  def new
    @storehouse = Storehouse.new
    render :form
  end

  def create
    @storehouse = Storehouse.new(storehouse_params)
    if @storehouse.save
      redirect_to admin_storehouses_path
    else
      flash[:alert] = '新建失败'
      redirect_to :back
    end
  end

  def edit
    render :form
  end

  def update
    if @storehouse.update(storehouse_params)
      return redirect_to session[:return_to] if session[:return_to]
      redirect_to admin_storehouses_path
    else
      flash[:alert] = '修改失败'
      redirect_to :back
    end
  end

  def destroy
    @storehouse.destroy
    redirect_to :back
  end

  private 
    def set_storehouse
      @storehouse = Storehouse.find(params[:id])
    end

    def storehouse_params
      params.require(:storehouse).permit(:name, :detail)
    end
end
