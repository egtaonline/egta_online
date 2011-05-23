module GamesHelper
  include ApplicationHelper
  
  def headers
    @headers ||= ["Name", "Type", "Size", "Simulator"]
  end
  
  def index_fields(entry)
    [Hash[:value => entry.name, :controller => "games", :id => entry.id],
    Hash[:value => entry.class, :controller => "games", :id => entry.id],
    Hash[:value => entry.size, :controller => "games", :id => entry.id],
    Hash[:value => entry.simulator.fullname, :controller => "simulators", :id => entry.simulator.id]]
  end
  
  def show_fields(entry)
    temp_array = [Hash[:name => "Name", :value => entry.name], Hash[:name => "Size", :value => entry.size], Hash[:name => "Description", :value => entry.description]]
    entry.parameters.each_pair { |x, y| temp_array << Hash[:name => x.capitalize, :value => y]}
    temp_array
  end
  
  def document_actions
    render :partial => "games/document_actions"
  end
end