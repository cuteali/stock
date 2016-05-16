class Promoter < ActiveRecord::Base
  has_many :users
  has_many :images, as: :target

  enum sex: [:man, :woman]

  scope :latest, -> { order('created_at DESC') }

  def sex_name
    man? ? '男' : '女'
  end
end
