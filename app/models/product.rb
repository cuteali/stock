class Product < ActiveRecord::Base
  belongs_to :category
  belongs_to :sub_category
  belongs_to :hot_category
  has_many :images, as: :target
  belongs_to :unit
  has_many :adverts
  belongs_to :detail_category
  has_one :cart_item
  scope :state, -> {where(state:1)}

  def self.get_select_category_html(options)
    html = ""
    html << "<select id='product_sub_category_id' name='product[sub_category_id]' class='form-control'>" if options
    html << "<option value=''>选择子类别</option>" if options
    options.each do |option|
      html << "<option value='#{option.id}'>#{option.name}</option>"
    end
    html << "</select>" if options
    return html
  end

  def self.get_select_sub_category_html(options)
    html = ""
    html << "<select id='product_detail_category_id' name='product[detail_category_id]' class='form-control'>" if options
    html << "<option value=''>选择具体类别</option>" if options
    options.each do |option|
      html << "<option value='#{option.id}'>#{option.name}</option>"
    end
    html << "</select>" if options
    return html
  end
end
