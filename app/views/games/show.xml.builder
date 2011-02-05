xml.instruct! :xml, :version=>"1.0"
xml.nfg(:name=>@game.name, :description=>@game.description) do |nfg|
  #nfg.players do |players|
  #  [:one,:two,:three].each do |player_name|
  #    players.player(:id=>player_name)
  #  end
  #end
  nfg.actions do |actions|
    @game.strategies.each do |strategy|
      actions.action(:id=>strategy.name)
    end
  end
  nfg.payoffs do |payoffs|
    @game.profiles.each do |profile|
      payoffs.payoff do |payoff|
        profile.strategies.uniq.each do |strategy|
          payoff.outcome(:action=>strategy.name,
                         :count=>profile.strategy_count(strategy),
                         :value=>profile.payoff_to_strategy(strategy))
        end
      end
    end
  end
end