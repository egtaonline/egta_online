module SimulatorsHelper
  include ApplicationHelper
  
  def headers
    @headers ||= ["Name", "Version"]
  end
  
  def index_fields(entry)
    [Hash[:value => entry.name, :controller => "simulators", :id => entry.id], Hash[:value => entry.version, :controller => "simulators", :id => entry.id]]
  end
  
  def show_fields(entry)
    temp_array = [Hash[:name => "Name", :value => entry.name], Hash[:name => "Version", :value => entry.version], Hash[:name => "Description", :value => entry.description]]
    entry.parameters.each_pair { |x, y| temp_array << Hash[:name => x.capitalize, :value => y]}
    temp_array
  end
  
  def document_actions
    render :partial => "simulators/document_actions"
  end
end