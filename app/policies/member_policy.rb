class MemberPolicy
  attr_reader :current_member, :model

  def initialize(current_member, model)
    @current_member = current_member
    @member = model
  end

  def index?
    @current_member.admin?
  end

  def edit?
    @current_member.admin?
  end

  def update?
    @current_member.admin?
  end

  def destroy?
    return false if @current_member == @member
    @current_member.admin?
  end
end
