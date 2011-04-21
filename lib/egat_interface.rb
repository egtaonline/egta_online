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
  gp.each_index {|i| gp[i][:regret] = profiles[i]["regret"].to_f; gp[i].save!}
  game[:regret_updated_at] = Time.now.getutc
  game.save!
  return true
end

#Find the regret over all actions in a given game, using EGAT. Write regret to strategy[:regret].
#Also write timestamp to game[:robust_regret_updated_at]
def generate_robust_regret(game)
  #EGAT currently reads games from an xml file. XMLs are generated every time in case Game was updated since last call.
  file = File.new("/tmp/#{game.id}.xml","w")
  file.puts build_game_xml(game)
  file.close
  
  h = Hash.from_xml(`#{::Rails.root.to_s}/bin/egat-0.9-SNAPSHOT/egat robust-regret -f /tmp/#{game.id}.xml -sym`)
  h = h["actions"]["action"]
  
  h.each{|x| game.strategies.detect{|y| y[:name] == x["id"]}[:regret]=x["regret"].to_f}
  game[:robust_regret_updated_at] = Time.now.getutc
  game.save!
end

#Returns a hash of strategies where key=>strategy, value=>probability
#Mixed strategy equilibrium saved as a hash in game[:rd_results].
#The regret of all players playing the eq. (assuming symmetric game) is saved as game[:rd_regret]
#Lastly, a timestamp is saved at game[:rd_updated_at]
def run_replicator_dynamics(game, iterations = 1000, l_inf_threshold = 0.0001)
  file = File.new("/tmp/#{game.id}.xml","w")
  file.puts build_game_xml(game)
  file.close
  
  h = Hash.from_xml(`#{::Rails.root.to_s}/bin/egat-0.9-SNAPSHOT/egat rd -f /tmp/#{game.id}.xml -sym --tolerance #{l_inf_threshold} --max-iterations #{iterations}`)
  parsed = {}
  h["profile"]["strategy"][0]["action"].each do |x|
    parsed.merge!(Hash[x["id"],x["probability"].to_f])
  end
  
  game[:rd_results] = parsed
  game[:rd_regret] = find_regret(game,Array.new(game.size,parsed))
  game[:rd_updated_at] = Time.now.getutc
  game.save!
  
  return true
end

#This should return which profiles are dominated, however this functionality doesn't seem to work
#in EGAT at the moment...
def run_ieds(game)
  return false
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

def find_regret(game, strategy_array)
  max = 0
  game.strategies.each do |e|
    compare = find_utility(game, Array[Hash[e.name, 1.0]].concat(strategy_array[1..-1]))
    if compare > max
      max = compare
    end
  end
  
  
  return [0,max - find_utility(game, strategy_array)].max 
end  

#strategy_array is an array of MIXED strategies per player. Mixed strategies are hashes where each key=>name, value=>probability.
#Utility is with respect to the first player(index) in the strategy_array
def find_utility(game, strategy_array)
  if strategy_array.length <= 1
    return nil
  end   
  
  utility = 0
  strategies = strategy_array.collect {|e| e.keys}
  strategies[0].product(*strategies[1..-1]) do |profile|
    probability = 1
    profile.each_index {|i| probability*=strategy_array[i][profile[i]]} 
    u = game.profiles.detect{|x| x.strategy_array == profile.sort}.payoff_to_strategy(profile[0])
    utility += probability*u
  end
  
  utility
end