class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [:edit, :update, :destroy, :user_statistics]
  
  def index
    if current_member.spreader?
      @q = current_member.promoter.users.ransack(params[:q])
    else
      @q = User.ransack(params[:q])
    end
    if params[:by_money]
      @users = @q.result.order_by_money.page(params[:page])
    else
      @users = @q.result.latest.page(params[:page])
    end
  end

  def new
    @user = User.new
  end

  def edit
  end

  def update
    image_params = params[:user][:image]
    if @user.update(user_params)     
      ImageUtil.image_upload(image_params,"User",@user.id)
      return redirect_to session[:return_to] if session[:return_to]
      redirect_to admin_users_path
    else
      render 'edit' 
    end
  end

  def destroy
    @user.destroy
    redirect_to :back
  end

  def create
    image_params = params[:user][:image]
    @user = User.new(user_params)
    @user.unique_id = SecureRandom.urlsafe_base64
    @user.user_id = SecureRandom.hex(10)
    @user.phone_num = AesUtil.aes_encrypt($key, params[:user][:phone])
    if @user.save
      ImageUtil.image_upload(image_params,"User",@user.id)
      redirect_to admin_users_path
    else
      render 'new'
    end
  end

  def user_statistics
    @orders = @user.orders.normal_orders.latest
    select_time = true if params[:start_time].present? && params[:end_time].present?
    @date = params[:created_date].present? ? params[:created_date] : "one_days"
    @today = Date.today
    @categories, @series, @start_time, @end_time, @count, @min_tick, @total = Order.chart_data(@orders, @date, @today, select_time, params)
    @order_stats = Order.get_order_stats(@total, @start_time, @end_time)
    @chart = Order.chart_base_line(@categories, @series, @min_tick) if @categories.present?
    @categories_amount, @series_amount, start_time, end_time, @amount, @min_tick_amount = Order.chart_data_amount(@orders, @date, @today, select_time, params)
    @chart_amount = Order.chart_base_line_amount(@categories_amount, @series_amount, @min_tick_amount) if @categories_amount.present?
  end

  private 

    def image_upload(image_params,model_name,model_id)
      image_params.each do |img|
        Image.create(image:img,target_type:model_name,target_id:model_id)
      end
    end 

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:user_name, :identification, :token, :address_id, :phone, :rand, :promoter_id)
    end
end
