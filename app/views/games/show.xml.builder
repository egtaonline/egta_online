xml.instruct! :xml, :version=>"1.0"
xml.nfg(:name=>resource.simulator.fullname, :description=>resource.parameter_hash) do |nfg|

  nfg.players do |players|
    for i in 1..@profiles.first.size do
      players.player(:id=>"player#{i}")
    end
  end
  nfg.actions do |actions|
    Profile.extract_strategies(@profiles).each do |strategy|
      actions.action(:id=>strategy)
    end
  end
  nfg.payoffs do |payoffs|
    @profiles.each do |profile|
      payoffs.payoff do |payoff|
        profile.role_instances.first.strategy_array.uniq.each do |strategy|
          payoff.outcome(:action=>strategy,
                         :count=>profile.role_instances.first.strategy_array.count(strategy),
                         :value=>profile.role_instances.first.payoff_avgs[strategy])
        end
      end
    end
  end
end