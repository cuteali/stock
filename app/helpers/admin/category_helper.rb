module Admin::CategoryHelper
  def get_select_category_html(options, id, name, first_option)
    html = ""
    html << "<select id='#{id}' name='#{name}' class='form-control'>" if options
    html << "<option value=''>#{first_option}</option>" if options
    options.each do |option|
      html << "<option value='#{option.id}'>#{option.name}</option>"
    end
    html << "</select>" if options
    return html
  end
end
