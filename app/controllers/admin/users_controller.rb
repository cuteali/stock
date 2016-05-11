class Admin::UsersController < Admin::BaseController
  before_action :set_user,only:[:edit,:update,:destroy]
  
  def index
    @q = User.ransack(params[:q])
    @users = @q.result.latest.page(params[:page])
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
    redirect_to admin_users_path
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
      params.require(:user).permit(:user_name,:identification,:token,:address_id,:phone,:rand,:address_id)
    end
end
