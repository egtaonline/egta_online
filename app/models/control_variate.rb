class ControlVariate
  include Mongoid::Document
  field :destination_id
  field :adjustment_coefficient_record_id
  field :acr_game_id
  embedded_in :game

  def type
    "Control Variates"
  end

  def apply_cv(source_id, features)
    adjustment_coefficient_record = Game.find(source_id).adjustment_coefficient_records.create!
    self.update_attributes(:acr_game_id => source_id, :adjustment_coefficient_record_id => adjustment_coefficient_record.id)
    Stalker.enqueue 'calculate_cv', :game => self.game.id.to_s, :cv => self.id.to_s, :name => "#{game.name}:cv:#{source_id}"
  end

  def transform_game(name)
    trans_game = Game.new(:name => name, :parameters => self.game.parameters, :size => self.game.size)
    self.game.simulator.games << trans_game
    trans_game.save!
    self.game.strategies.each {|strat| trans_game.strategies.create!(:name => strat.name)}
    self.game.features.each {|f| if f.expected_value == nil; f.update_attributes(:expected_value => f.sample_avg); end}
    adjustment_coefficient_record = Game.find(self.acr_game_id).adjustment_coefficient_records.find(self.adjustment_coefficient_record_id)
    self.game.profiles.each do |profile|
      trans_profile = trans_game.profiles.create!
      profile.players.each do |player|
        trans_player = trans_profile.players.create!(:strategy => player.strategy)
        player.payoffs.each do |payoff|
          adjusted = payoff.payoff
          self.game.features.each do |f|
            if adjustment_coefficient_record.feature_hash[f.name] != nil
              adjusted += adjustment_coefficient_record.feature_hash[f.name].to_f*(f.feature_samples.where(:sample_id => payoff.sample_id).first.value - f.expected_value)
            end
          end
          trans_player.payoffs.create!(:payoff => adjusted, :sample_id => payoff.sample_id)
        end
      end
    end
    if trans_game.save!
      return trans_game
    else
      nil
    end
  end
end
