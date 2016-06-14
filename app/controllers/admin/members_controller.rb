class Admin::MembersController < Admin::BaseController
  before_action :set_member, only: [:edit, :update, :destroy, :system_setting, :update_system_setting]
  before_filter :authenticate_member!
  after_action :verify_authorized

  def index
    authorize Member
    @members = Member.page(params[:page])
  end

  def edit
    authorize @member
    render :form
  end

  def update
    authorize @member
    if params[:member][:password]
      @member.password = params[:member][:password]
      @member.password_confirmation = params[:member][:password]
    end
    if @member.update(member_params)
      redirect_to :back, notice: '修改成功'
    else
      flash[:alert] = '修改失败'
      redirect_to :back
    end
  end

  def destroy
    authorize @member
    @member.destroy
    redirect_to :back
  end

  def system_setting
    authorize @member
    @system_setting = SystemSetting.first_or_create
  end

  def update_system_setting
    authorize @member
    @system_setting = SystemSetting.first
    if @system_setting.update(delivery_price: params[:system_setting][:delivery_price].to_f)
      redirect_to :back, notice: '设置成功'
    else
      flash[:alert] = '设置失败'
      redirect_to :back
    end
  end

  private 
    def set_member
      @member = Member.find(params[:id])
    end

    def member_params
      params.require(:member).permit(:name, :email, :role, :promoter_id)
    end
end