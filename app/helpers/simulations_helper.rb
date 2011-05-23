module SimulationsHelper
  def headers
    @headers ||= ["State", "Game", "Profile"]
  end
  
  def index_fields(entry)
    [Hash[:value => entry.state, :controller => "simulations", :id => entry.id],
    Hash[:value => entry.profile.game.name, :controller => "games", :id => entry.profile.game_id],
    Hash[:value => entry.profile.name, :controller => "profiles", :id => entry.profile_id]]
  end
  
  def index_actions
    render :partial => "simulations/purge"
  end
  
  def show_fields(entry)
    [Hash[:name => "Account", :value => entry.account.username],
    Hash[:name => "Profile", :value => entry.profile.name],
    Hash[:name => "Size", :value => entry.size],
    Hash[:name => "Job ID", :value => entry.job_id],
    Hash[:name => "State", :value => entry.state],
    Hash[:name => "Error Messages", :value => entry.error_message]]
  end
end