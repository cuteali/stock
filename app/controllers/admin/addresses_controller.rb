class Admin::AddressesController < Admin::BaseController
  before_action :set_address, only: [:edit, :update, :destroy]
  
  def index
    @q = Address.ransack(params[:q])
    @address = @q.result.latest.page(params[:page])
  end

  def new
    @address = Address.new
  end

  def edit
  end

  def update
    if @address.update(address_params)
      return redirect_to session[:return_to] if session[:return_to]
      redirect_to admin_addresses_path
    else
      render 'edit' 
    end
  end

  def destroy
    @address.destroy
    redirect_to :back
  end

  def create
    @address = Address.new(address_params)
    @address.unique_id = SecureRandom.urlsafe_base64
    if @address.save
      redirect_to admin_addresses_path
    else
      render 'new'
    end
  end

  private 
    def set_address
      @address = Address.find(params[:id])
    end

    def address_params
      params.require(:address).permit(:province, :city, :region, :detail, :user_id, :receive_name, :receive_phone)
    end
end
