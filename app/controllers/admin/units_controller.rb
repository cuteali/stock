class Admin::UnitsController < Admin::BaseController

  before_action :set_unit,only:[:edit,:update,:destroy]
  before_filter :authenticate_member!
  after_action :verify_authorized, only: :destroy
  
  def index
    @units = Unit.all
  end

  def new
    @unit = Unit.new
  end

  def edit
  end

  def update
    if @unit.update(unit_params)
        return redirect_to session[:return_to] if session[:return_to]
        redirect_to admin_units_path
      else
        render 'edit' 
      end
  end

  def destroy
    authorize @unit
    @unit.destroy
    redirect_to :back
  end

  def create
    @unit = Unit.new(unit_params)
    if @unit.save
      redirect_to admin_units_path
    else
      render 'new'
    end
  end

  private 
    def set_unit
      @unit = Unit.find(params[:id])
    end

    def unit_params
      params.require(:unit).permit(:name)
    end
end
