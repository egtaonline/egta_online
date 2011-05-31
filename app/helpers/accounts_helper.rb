module AccountsHelper
  include ApplicationHelper

  def headers
    @headers ||= ["Username"]
  end

  def index_fields(entry)
    [Hash[:value => entry.username, :controller => "accounts", :id => entry.id]]
  end

  def show_fields(entry)
    [Hash[:name => "Username", :value => entry.username], Hash[:name => "Max concurrent simulations", :value => entry.max_concurrent_simulations]]
  end

  def editable?
    true
  end
end