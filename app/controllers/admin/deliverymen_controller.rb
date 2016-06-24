class Admin::DeliverymenController < Admin::BaseController

  before_action :set_deliveryman,only:[:edit,:update,:destroy]
  before_filter :authenticate_member!
  
  def index
    @deliverymen = Deliveryman.page(params[:page])
  end

  def new
    @deliveryman = Deliveryman.new
  end

  def create
    @deliveryman = Deliveryman.new(deliveryman_params)
    if @deliveryman.save
      redirect_to admin_deliverymen_path
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @deliveryman.update(deliveryman_params)
      return redirect_to session[:return_to] if session[:return_to]
      redirect_to admin_deliverymen_path
    else
      render 'edit' 
    end
  end

  def destroy
    @deliveryman.destroy
    redirect_to :back
  end

  private 
    def set_deliveryman
      @deliveryman = Deliveryman.find(params[:id])
    end

    def deliveryman_params
      params.require(:deliveryman).permit(:name, :phone)
    end
end
