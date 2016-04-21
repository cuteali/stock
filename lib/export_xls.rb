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
end