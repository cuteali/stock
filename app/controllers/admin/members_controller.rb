class Admin::MembersController < Admin::BaseController
  before_action :set_member, only: [:edit, :update, :destroy]
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

  private 
    def set_member
      @member = Member.find(params[:id])
    end

    def member_params
      params.require(:member).permit(:name, :email, :role)
    end
end