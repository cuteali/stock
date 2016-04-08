class SubCategoryPolicy
  attr_reader :current_member, :model

  def initialize(current_member, model)
    @current_member = current_member
    @member = model
  end

  def destroy?
    @current_member.admin?
  end
end
