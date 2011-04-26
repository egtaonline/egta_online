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
    self.acr_game_id = source_id
    adjustment_coefficient_record = Game.find(source_id).adjustment_coefficient_records.create!
    adjustment_coefficient_record.save!
    self.adjustment_coefficient_record_id = adjustment_coefficient_record.id
    adjustment_coefficient_record.calculate_coefficients(features.collect {|x| Game.find(source_id).features.where(:name => x).first})
    g = transform_game("#{game.name}:cv:#{source_id}")
    self.update_attributes(:destination_id => g.id)
  end

  def transform_game(name)
    trans_game = Game.new(:name => name)
    self.game.simulator.games << trans_game
    trans_game.save!
    self.game.strategies.each {|strat| trans_game.strategies.create!(:name => strat.name)}
    self.game.features.each {|f| if f.expected_value == nil; f.update_attributes(:expected_value => f.sample_avg); end}
    adjustment_coefficient_record = Game.find(self.acr_game_id).adjustment_coefficient_records.find(self.adjustment_coefficient_record_id)
    self.game.profiles.each do |profile|
      trans_profile = trans_game.profiles.create!
      profile.players.each do |player|
        trans_player = trans_profile.players.create!
        player.payoffs.each do |payoff|
          adjusted = payoff.payoff
          self.features.each do |f|
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
