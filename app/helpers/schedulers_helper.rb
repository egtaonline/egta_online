module SchedulersHelper
  include ApplicationHelper

  def headers
    @headers ||= ["Type", "Target", "Active"]
  end

  def index_fields(entry)
    [Hash[:value => entry.class, :controller => entry.class.to_s.underscore.pluralize, :id => entry.id],
    Hash[:value => entry.target.name, :controller => entry.target.class.to_s.underscore.pluralize, :id => entry.target.id],
    Hash[:value => entry.active, :controller => entry.class.to_s.underscore.pluralize, :id => entry.id]]
  end
end