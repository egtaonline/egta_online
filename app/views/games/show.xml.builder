xml.instruct! :xml, :version=>"1.0"
xml.nfg(:name=>resource.simulator.fullname, :description=>resource.parameter_hash) do |nfg|

  nfg.players do |players|
    for i in 1..@profiles.first.proto_string.split(": ")[1].split(", ").count do
      players.player(:id=>"player#{i}")
    end
  end
  nfg.actions do |actions|
    resource.roles.first.strategy_array.each do |strategy|
      actions.action(:id=>strategy)
    end
  end
  nfg.payoffs do |payoffs|
    @profiles.each do |profile|
      payoffs.payoff do |payoff|
        strategies = profile.proto_string.split(": ")[1].split(", ")
        strategies.uniq.each do |strategy|
          payoff.outcome(:action=>strategy,
                         :count=>strategies.count(strategy),
                         :value=>profile.role_instances.first.strategy_instances.where(name: strategy).payoff)
        end
      end
    end
  end
end