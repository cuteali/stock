class Member < ActiveRecord::Base
  enum role: [:user, :editor, :admin]
  after_initialize :set_default_role, :if => :new_record?

  def set_default_role
    self.role ||= :user
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def role_name
    if user?
      return '普通管理员'
    elsif editor?
      return '一级管理员'
    elsif admin?
      return '超级管理员'
    end
  end
end
