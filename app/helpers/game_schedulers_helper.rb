module GameSchedulersHelper
  include ApplicationHelper
  
  def headers
    @headers ||= ["Game", "Active"]
  end
  
  def index_fields(entry)
    [Hash[:value => entry.game, :id => entry.game.id], Hash[:value => entry.active, :id => entry.id]]
  end

  def show_fields(entry)
    [Hash[:name => "Game", :value => entry.game.name], 
    Hash[:name => "Max samples", :value => entry.max_samples],
    Hash[:name => "Samples per simulation", :value => entry.samples_per_simulation],
    Hash[:name => "Process memory (in MB)", :value => entry.process_memory],
    Hash[:name => "Time per sample", :value => entry.time_per_sample],
    Hash[:name => "Jobs per request", :value => entry.jobs_per_request],
    Hash[:name => "Active?", :value => entry.active]]
  end
  
  def editable?
    true
  end
end