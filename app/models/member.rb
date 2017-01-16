class Member < ActiveRecord::Base
  attr_accessor :login

  belongs_to :promoter
  has_many :merge_orders

  validates :name,
  presence: true,
  uniqueness: {
    message: '用户名不能重复',
    case_sensitive: false
  }

  enum role: [:user, :editor, :admin, :spreader]
  after_initialize :set_default_role, :if => :new_record?

  def set_default_role
    self.role ||= :spreader
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :authentication_keys => [:login]

  def role_name
    if user?
      return '普通管理员'
    elsif editor?
      return '一级管理员'
    elsif admin?
      return '超级管理员'
    elsif spreader?
      return '推广管理员'
    end
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions.to_h).where(["lower(name) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    elsif conditions.has_key?(:name) || conditions.has_key?(:email)
      where(conditions.to_h).first
    end
  end
end
