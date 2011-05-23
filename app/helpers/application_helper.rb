module ApplicationHelper
  def page_title(action, class_name)
    case action
    when :new
      "New #{class_name.titleize}"
    when :show
      "#{class_name.titleize} Information"
    when :index
      "#{class_name.pluralize.titleize}"
    when :edit
      "Edit #{class_name.titleize}"
    end
  end

  def new_link(klass_name, plural_name)
    link_to "New #{klass_name}", "/#{plural_name}/new"
  end

  def edit_link(single_name, plural_name)
    link_to "Edit #{single_name}", url_for(:action => "edit", :id => entry.id) if editable?
  end
  
  def document_actions
  end
  
  def index_actions
  end
  
  def editable?
    false
  end
end
