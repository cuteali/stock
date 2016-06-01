module ExportXls
  def self.export_excel
    xls_report = StringIO.new
    book = ExportXls.new_excel
    book_excel = book[0]
    book_sheet = book[1]
    export_title = ['大分类', '小分类', '具体分类']
    sing_sheet = []
    sing_sheet << export_title

    DetailCategory.all.each do |dc|
      sing_sheet << [dc.category.try(:name), dc.sub_category.try(:name), dc.name].flatten
    end
    sing_sheet.each_with_index do |new_sheet,index|
      book_sheet.insert_row(index,new_sheet)
    end
    book_excel.write(xls_report)
    return xls_report.string
  end

  def self.new_excel
    Spreadsheet.client_encoding = "UTF-8"
    book = Spreadsheet::Workbook.new
    bold_heading = Spreadsheet::Format.new(:weight => :bold, :align => :merge)
    sheet = book.create_worksheet :name => "分类管理"
    return [book,sheet,bold_heading]
  end

  def self.export_product_excel(category)
    xls_report = StringIO.new
    book = ExportXls.new_product_excel
    book_excel = book[0]
    book_sheet = book[1]
    export_title = ['大分类', '小分类', '具体分类', '产品名称', '单位', '价格', '原价', '描述', '简介', '规格', '库存', '销量', '排序', '首页展示', '是否上架']
    sing_sheet = []
    sing_sheet << export_title

    category.products.all.each do |p|
      sing_sheet << [p.category.try(:name), p.sub_category.try(:name), p.detail_category.try(:name), p.name, p.unit.try(:name), p.price.to_s, p.old_price.to_s,
        p.info, p.desc, p.spec, p.stock_num, p.sale_count, p.sort, '是', '是'].flatten
    end
    sing_sheet.each_with_index do |new_sheet,index|
      book_sheet.insert_row(index,new_sheet)
    end
    book_excel.write(xls_report)
    return xls_report.string
  end

  def self.new_product_excel
    Spreadsheet.client_encoding = "UTF-8"
    book = Spreadsheet::Workbook.new
    bold_heading = Spreadsheet::Format.new(:weight => :bold, :align => :merge)
    sheet = book.create_worksheet :name => "产品"
    return [book,sheet,bold_heading]
  end
end