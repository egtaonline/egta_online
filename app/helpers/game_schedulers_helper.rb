module GameSchedulersHelper
  include ApplicationHelper

  def headers
    @headers ||= ["Game", "Active"]
  end

  def index_fields(entry)
    [Hash[:value => entry.game.name, :controller => "games", :id => entry.game.id],
    Hash[:value => entry.active, :controller => "game_schedulers", :id => entry.id]]
  end

  def show_fields(entry)
    [Hash[:name => "Simulator", :value => entry.simulator.fullname],
    Hash[:name => "Run time configuration", :value => entry.run_time_configuration.parameters],
    Hash[:name => "Max samples", :value => entry.max_samples],
    Hash[:name => "Samples per simulation", :value => entry.samples_per_simulation],
    Hash[:name => "Process memory (in MB)", :value => entry.process_memory],
    Hash[:name => "Time per sample", :value => entry.time_per_sample],
    Hash[:name => "Jobs per request", :value => entry.jobs_per_request],
    Hash[:name => "Active?", :value => entry.active]]
  end

  def document_actions
    render :partial => "game_schedulers/document_actions"
  end

  def editable?
    true
  end
end