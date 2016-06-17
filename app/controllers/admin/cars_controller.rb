class Admin::CarsController < Admin::BaseController

  before_action :set_car,only:[:edit,:update,:destroy]
  before_filter :authenticate_member!
  
  def index
    @cars = Car.all
  end

  def new
    @car = Car.new
  end

  def create
    @car = Car.new(car_params)
    if @car.save
      redirect_to admin_cars_path
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @car.update(car_params)
      return redirect_to session[:return_to] if session[:return_to]
      redirect_to admin_cars_path
    else
      render 'edit' 
    end
  end

  def destroy
    @car.destroy
    redirect_to :back
  end

  private 
    def set_car
      @car = Car.find(params[:id])
    end

    def car_params
      params.require(:car).permit(:name)
    end
end
