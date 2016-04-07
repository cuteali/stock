class Admin::MembersController < Admin::BaseController
  before_filter :authenticate_member!
  before_action :set_member, only: [:edit, :update, :destroy, :show]

  def index
    authorize Member
    @members = Member.page(params[:page])
  end

  def edit
    render :form
  end

  def update
    if @member.update(member_params)
      redirect_to :back, notice: '操作成功'
    end
  end

  def destroy
    @member.destroy
    redirect_to admin_members_path
  end

  private 
    def set_member
      @member = Member.find(params[:id])
    end

    def member_params
      params.require(:member).permit(:name, :email, :role)
    end
end