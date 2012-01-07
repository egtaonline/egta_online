xml.instruct! :xml, :version=>"1.0"
xml.nfg(:name=>resource.simulator.fullname, :description=>resource.parameter_hash) do |nfg|

  nfg.players do |players|
    for i in 1..@profiles.first.proto_string.split(": ")[1].split(", ").count do
      players.player(:id=>"player#{i}")
    end
  end
  nfg.actions do |actions|
    resource.roles.first.strategies.each do |strategy|
      actions.action(:id=>strategy.name)
    end
  end
  nfg.payoffs do |payoffs|
    @profiles.each do |profile|
      payoffs.payoff do |payoff|
        strategies = profile.name.split(": ")[1].split(", ")
        strategies.each do |strategy|
          payoff.outcome(:action=>strategy.split(" ")[1],
                         :count=>strategy.split(" ")[0],
                         :value=>profile.role_instances.first.strategy_instances.where(name: strategy.split(" ")[1]).first.payoff)
        end
      end
    end
  end
end