module Admin::UserHelper
  def user_rand
    [["铜","铜"],["银","银"],["金","金"],["钻","钻"]]
  end

  def get_image_url(obj)
    if obj.images.present?
      image = obj.images.latest.first
      image.image.url
    end
  end
end
