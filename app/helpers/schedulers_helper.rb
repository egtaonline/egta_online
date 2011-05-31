module SchedulersHelper
  include ApplicationHelper

  def headers
    @headers ||= ["Type", "Simulator", "Active"]
  end

  def new_link(klass_name, plural_name)
    link_to 'New Game Scheduler', '/game_schedulers/new'
  end

  def index_fields(entry)
    [Hash[:value => entry.class, :controller => entry.class.to_s.underscore.pluralize, :id => entry.id],
    Hash[:value => entry.simulator.fullname, :controller => "simulators", :id => entry.simulator.id],
    Hash[:value => entry.active, :controller => entry.class.to_s.underscore.pluralize, :id => entry.id]]
  end
end