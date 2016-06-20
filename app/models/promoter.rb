class Promoter < ActiveRecord::Base
  has_many :users
  has_many :images, as: :target

  enum sex: [:man, :woman]

  before_create :generate_promoter_no

  scope :latest, -> { order('created_at DESC') }

  def sex_name
    man? ? '男' : '女'
  end

  private
    def generate_promoter_no
      max_promoter_no = Promoter.maximum(:promoter_no) || 8000
      self.promoter_no = max_promoter_no.succ
    end
end
