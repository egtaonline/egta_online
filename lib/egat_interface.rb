require 'builder'

#Find the regret over all profiles in a given game, using EGAT.  Write regret to profile[:regret], and save all profiles.
#Also write timestamp to game[:regret_updated_at].
def generate_regret(game)
  #EGAT currently reads games from an xml file. XMLs are generated every time in case Game was updated since last call.
  file = File.new("/tmp/#{game.id}.xml","w")
  file.puts build_game_xml(game)
  file.close
  
  h = Hash.from_xml(`#{::Rails.root.to_s}/bin/egat-0.9-SNAPSHOT/egat regret -f /tmp/#{game.id}.xml -sym`)
  h = h["profiles"]["profile"]
  
  #Parse EGAT output.
  profiles = []
  h.each{|x| 
    p = {}
    p["regret"] = x["regret"]
    p["profile"] = create_strategy_array(x["outcome"])
    profiles << p
    }
  profiles.sort! {|a,b| a["profile"] <=> b["profile"]}
  gp = game.profiles.sort! {|a,b| a.strategy_array <=> b.strategy_array}
  
  #Write and save output
  if gp.size != profiles.size
    print "Error! Inconsistent number of profiles!"
    return false
  end
  gp.each_index {|i| gp[i][:regret] = profiles[i]["regret"]; gp[i].save!}
  game[:regret_updated_at] = Time.now.getutc
  game.save!
  return true
end

######
#Helper functions
######

#NOTE: Strategies may be in an array if there is more than one strategy in the profile. 
#Otherwise the strategy will be in a singular hash.  
def create_strategy_array(actions)
  arr = []
  if actions.class != Array
    actions = [actions]
  end
  actions.each{|a| a["count"].to_i.times { arr << a["action"] }}
  arr.sort!
end

#Builds an xml output of the Game model that is EGAT compatible.
def build_game_xml(game)
  xml = Builder::XmlMarkup.new(:indent=>2)
  xml.instruct! :xml, :version=>"1.0"
  xml.nfg(:name=>game.name, :description=>game.description) do |nfg|

  nfg.players do |players|
    for i in 1..game.size do
      players.player(:id=>"player#{i}")
    end
  end
  nfg.actions do |actions|
    game.strategies.each do |strategy|
      actions.action(:id=>strategy.name)
    end
  end
  nfg.payoffs do |payoffs|
    game.profiles.each do |profile|
      payoffs.payoff do |payoff|
        profile.strategy_array.uniq.each do |strategy|
          payoff.outcome(:action=>strategy,
                         :count=>profile[strategy.tr(".", "|")],
                         :value=>profile.payoff_to_strategy(strategy))
        end
      end
    end
  end
end
end
