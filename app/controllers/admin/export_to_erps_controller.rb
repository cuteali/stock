class Admin::ExportToErpsController < Admin::BaseController
  before_filter :authenticate_member!

  def index
    respond_to do |format|
      format.html
      format.xls {
                send_data(ExportErpXls.export_excel(params[:type]),
                :type => "text/excel;charset=utf-8; header=present",
                :filename => Time.now.to_s(:db).to_s.gsub(/[\s|\t|\:]/,'_') + rand(99999).to_s + ".xls")
              }
    end
  end
end
