xml.instruct! :xml, :version=>"1.0"
xml.nfg(:name=>@game.name, :description=>@game.description) do |nfg|

  nfg.players do |players|
    for i in 1..@game.size do
      players.player(:id=>"player#{i}")
    end
  end
  nfg.actions do |actions|
    @game.strategies.each do |strategy|
      actions.action(:id=>strategy.name)
    end
  end
  nfg.payoffs do |payoffs|
    @game.profiles.each do |profile|
      payoffs.payoff do |payoff|
        profile.strategy_array.uniq.each do |strategy|
          payoff.outcome(:action=>strategy,
                         :count=>profile.players.where(:strategy => strategy).count,
                         :value=>profile.payoff_to_strategy(strategy))
        end
      end
    end
  end
end