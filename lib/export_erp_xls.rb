module ExportErpXls
  def self.export_excel(type, id=nil)
    xls_report = StringIO.new
    sing_sheet = []
    sheet_name, sing_sheet = ExportErpXls.get_sheet(type, sing_sheet, id)
    book = ExportErpXls.new_excel(sheet_name)
    book_excel = book[0]
    book_sheet = book[1]

    sing_sheet.each_with_index do |new_sheet,index|
      book_sheet.insert_row(index,new_sheet)
    end

    book_excel.write(xls_report)
    return xls_report.string
  end

  def self.new_excel(sheet_name)
    Spreadsheet.client_encoding = "UTF-8"
    book = Spreadsheet::Workbook.new
    bold_heading = Spreadsheet::Format.new(:weight => :bold, :align => :merge)
    sheet = book.create_worksheet :name => sheet_name
    return [book,sheet,bold_heading]
  end

  def self.get_sheet(type, sing_sheet, id)
    case type
    when 'product'
      ['导出产品', ExportErpXls.sheet_product(sing_sheet)]
    when 'user'
      ['导出用户', ExportErpXls.sheet_user(sing_sheet)]
    when 'order'
      ['导出订单', ExportErpXls.sheet_order(sing_sheet, id)]
    end
  end

  def self.sheet_product(sing_sheet)
    export_title = ['编号', '产品名称', '大类别', '小类别', '具体类别', '热门类别', '单位', '销量', '库存数量', '现价', '原价', '进价', '规格', '单价', '产地', '备注']
    sing_sheet << export_title
    Product.all.each do |p|
      sing_sheet << [p.unique_id, p.name, p.category.try(:name), p.sub_category.try(:name),
        p.detail_category.try(:name), p.hot_category.try(:name), p.unit.try(:name),
        p.sale_count, p.stock_num, p.price, p.old_price, p.cost_price, p.spec, p.unit_price,
        p.origin, p.remark].flatten
    end
    sing_sheet
  end

  def self.sheet_user(sing_sheet)
    export_title = ['编号', '用户名', '状态', '地址', '电话', '注册时间', '推广人员']
    sing_sheet << export_title
    User.all.each do |u|
      state = u.identification == 0 ? '未认证' : '认证'
      address = u.addresses.first
      complete_address = address.try(:area).to_s + " " + address.try(:detail).to_s
      time = u.created_at.try(:strftime, "%Y-%m-%d %H:%M:%S")
      sing_sheet << [u.unique_id, u.user_name, state, complete_address, u.phone, time, u.promoter.try(:name)].flatten
    end
    sing_sheet
  end

  def self.sheet_order(sing_sheet, id)
    export_title = ['编号', '用户编号', '用户名称', '商品编号', '商品名称', '单价', '数量']
    sing_sheet << export_title
    if id.present?
      orders_products = OrdersProduct.where(order_id: id).order(:order_id)
    else
      orders_products = OrdersProduct.order(:order_id)
    end
    orders_products.each do |op|
      sing_sheet << [op.order.unique_id, op.user.try(:unique_id), op.user.try(:user_name),
        op.product.try(:unique_id), op.product.try(:name), op.product_price, op.product_num].flatten
    end
    sing_sheet
  end
end
