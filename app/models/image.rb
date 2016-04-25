class Image < ActiveRecord::Base
  belongs_to :target, polymorphic: true
  mount_uploader :image, ImageUploader

  scope :latest, -> { order('created_at DESC') }

  def self.get_images(instance)
    image_urls = instance.images.latest.map do |image|
      image.image.url
    end
  end
end
