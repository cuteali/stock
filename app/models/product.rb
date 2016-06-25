class Product < ActiveRecord::Base
  belongs_to :category
  belongs_to :sub_category
  belongs_to :detail_category
  belongs_to :hot_category
  belongs_to :unit
  has_many :cart_items
  has_many :images, as: :target, dependent: :destroy
  has_many :adverts
  has_many :orders_products, dependent: :destroy
  has_many :messages, as: :messageable
  has_many :product_admins
  has_many :bar_codes, dependent: :destroy

  scope :state, -> { where(state: 1) }
  scope :sorted, -> { order('sort DESC') }
  scope :order_sale, -> { order('sale_count DESC') }
  scope :hot, -> { where(hot_category_id: 2) }
  scope :by_page, -> (page_num) { page(page_num) if page_num }
  scope :order_by_stock_num, -> { order('stock_num ASC') }

  validates :sort, presence: true
  validates :sort, numericality: { only_integer: true, greater_than_or_equal_to: 1}

  HEADER_HASH = {
    '产品名称'  => :name,
    '产品描述'  => :desc,
    '产品详情'  => :info,
    '大类别'    => :category_id,
    '小类别'    => :sub_category_id,
    '具体类别'  => :detail_category_id,
    '热门类别'  => :hot_category_id,
    '排序'      => :sort,
    '状态'      => :state,
    '单位'      => :unit_id,
    '图片'      => :image,
    '库存数量'  => :stock_num,
    '销量'      => :sale_count,
    '价格'      => :price,
    '进价'      => :cost_price,
    '原始价格'  => :old_price,
    '规格'      => :spec,
    '单价'      => :unit_price,
    '产地'      => :origin,
    '备注'      => :remark
  }

  def save_bar_codes(params_bar_codes)
    if params_bar_codes
      bar_codes.destroy_all
      params_bar_codes.to_s.split(',').each do |bar_code|
        bar_codes.create(bar_code_no: bar_code)
      end
    end
  end

  def update_orders_product_cost_price(params_cost_price)
    orders_products.joins(:order).one_days(Date.today).where("orders.state in (?)", [0, 1, 4, 5]).each do |op|
      if op.update_columns(cost_price: params_cost_price)
        op.order.calculate_cost_price
      end
    end
  end

  def is_sold_off?
    state == 0
  end

  def update_cart_items_num
    if restricting_num.present?
      cart_items.each do |item|
        item.update(product_num: restricting_num) if item.product_num > restricting_num
      end
    end
  end

  def self.search_with_name_like(name_like, page)
    products = Product.state.joins(:category, :sub_category, :detail_category).
                              where{
                                (name.like "%#{name_like}%") | 
                                (category.name.like "%#{name_like}%") | 
                                (sub_category.name.like "%#{name_like}%") | 
                                (detail_category.name.like "%#{name_like}%")
                              }.order_sale.by_page(page)
    total_pages = products.total_pages.to_i
    if products.blank?
      name_arr = name_like.split('').map {|val| "detail_categories.name like '%#{val}%' or products.name like '%#{val}%'" }
      products = Product.state.joins(:detail_category).where(name_arr.join(" or ")).order_sale.sort_by {|u| u.name.count(name_like)}.reverse!.take(100)
    end
    [products, total_pages]
  end

  def self.valid_product_num_and_state(products)
    not_enough_products = []
    sold_off_products = []
    products.each do |p|
      product = Product.find_by(unique_id: p["unique_id"])
      if product.is_sold_off?
        sold_off_products << product.name
      end
      if product.stock_num < p["number"].to_i
        not_enough_products << product.name
      end
    end
    [not_enough_products, sold_off_products]
  end

  def restore_stock_num(number)
    self.stock_num += number.to_i
    self.sale_count -= number.to_i
    self.save
  end

  def add_sale_count(number)
    self.stock_num -= number.to_i
    self.sale_count += number.to_i
    self.save
  end

  def add_or_cut_stock_num(number)
    self.stock_num += number.to_i
    self.save
  end

  def self.init_sort
    Product.maximum(:sort) + 1
  end

  def self.validate_and_import(file_path)
    data = Product.parse_data(file_path)
    hash = Product.validate_data(data)
    return hash if hash[:error]

    # Product.insert_data(data)
    Product.delay.insert_data(data)
    # data[:data].size
  rescue => e
    Rails.logger.error "product importing error: #{e.message}"
    Rails.logger.error e.backtrace
    { error: true, message: '文件格式不正确' }
  end

  def self.parse_data(file_path, separator: ',')
    hash = { data: [] }
    test_line = File.foreach(file_path) { |line| break line }
    encoding = test_line =~ /产品名称|产品描述|产品详情|大类别/ ? 'UTF-8' : 'GBK' rescue 'GBK'
    File.foreach(file_path, encoding: encoding) do |line|
      next if line.blank?
      if hash[:headers].present?
        hash[:data] << Product.parse_fields(line, hash[:headers], separator: separator)
      else
        hash.merge!(headers: Product.parse_headers(line, separator: separator), separators_count: line.count(separator))
      end
    end
    hash
  end

  def self.validate_data(data)
    hash = {}
    if (HEADER_HASH.values.take(3) - data[:headers]).present?
      hash.merge!(error: true, message: '文件格式不正确')
    else
      data[:data].each { |attrs|
        if attrs[:name].blank?
          hash.merge!(error: true, message: '产品名称不能为空') and break
        elsif attrs[:category_id].blank?
          hash.merge!(error: true, message: '大类别不能为空') and break
        elsif attrs[:stock_num].blank?
          hash.merge!(error: true, message: '库存数量不能为空') and break
        elsif attrs[:price].blank?
          hash.merge!(error: true, message: '价格不能为空') and break
        end
      }
    end
    hash
  end

  def self.parse_headers(line, separator: ',')
    line.split(separator).map do |field_name|
      HEADER_HASH[field_name.strip]  
    end
  end

  def self.parse_fields(line, headers, separator: ',')
    line.split(separator).map.with_index.inject({line: line}) do |hash, (value, i)|
      hash.tap { |h| h[headers[i]] = value.strip if headers[i].present? }
    end
  end

  def self.insert_data(data)
    data[:data].each do |attrs|
      line = attrs.delete(:line)
      image = attrs.delete(:image)
      attrs[:sort] = Product.init_sort
      # attrs[:state] = 1
      attrs[:hot_category_id] = 1
      attrs[:unique_id] = SecureRandom.urlsafe_base64
      attrs[:price] = attrs[:price].to_f
      attrs[:cost_price] = attrs[:price].to_f if attrs[:cost_price].blank?
      attrs[:old_price] = attrs[:old_price].to_f
      product = Product.new(attrs)
      Product.where(attrs.slice(:name, :category_id, :sub_category_id, :detail_category_id, :price)).delete_all
      if product.save # 导入产品成功
        ImageUtil.image_upload(image, "Product", product.id) if image
      end
    end
  end
end
