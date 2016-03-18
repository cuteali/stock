class Product < ActiveRecord::Base
  belongs_to :category
  belongs_to :sub_category
  belongs_to :detail_category
  belongs_to :hot_category
  belongs_to :unit
  has_one :cart_item
  has_many :images, as: :target
  has_many :adverts

  scope :state, -> { where(state: 1) }
  scope :sorted, -> { order('sort DESC') }
  scope :hot, -> { where(hot_category_id: 2) }

  validates :sort, presence: true
  validates :sort, numericality: { only_integer: true, greater_than_or_equal_to: 1}

  def self.get_select_category_html(options, id, name)
    html = ""
    html << "<select id='#{id}' name='#{name}' class='form-control'>" if options
    html << "<option value=''>选择子类别</option>" if options
    options.each do |option|
      html << "<option value='#{option.id}'>#{option.name}</option>"
    end
    html << "</select>" if options
    return html
  end

  def self.get_select_sub_category_html(options, id, name)
    html = ""
    html << "<select id='#{id}' name='#{name}' class='form-control'>" if options
    html << "<option value=''>选择具体类别</option>" if options
    options.each do |option|
      html << "<option value='#{option.id}'>#{option.name}</option>"
    end
    html << "</select>" if options
    return html
  end

  def self.validate_stock_num(products)
    result = 0
    products.each do |p|
      product = Product.find_by(unique_id: p["unique_id"])
      if product.stock_num < p["number"].to_i
        result = 3
        break
      end
    end
    result
  end

  def self.edit_stock_num(products)
    pro_ids = []
    products.each do |p|
      product = Product.find_by(unique_id: p["unique_id"])
      if product.stock_num >= p["number"].to_i
        pro_ids << product.id
        product.stock_num -= p["number"].to_i
        product.sale_count += p["number"].to_i
        product.save
      else
        break
      end
    end
    pro_ids
  end

  def self.init_sort
    Product.maximum(:sort) + 1
  end
end
