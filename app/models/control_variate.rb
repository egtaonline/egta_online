class ControlVariate
  include Mongoid::Document
  include Transformation
  field :destination_id
  field :adjustment_coefficient_record_id
  field :feature_ids, :type => Array, :default => []
  embedded_in :game

  def features
    feature_ids.collect {|x| game.features.find(x)}
  end

  def type
    "Control Variates"
  end

  def apply_cv
    g = transform_game(game, ":cv")
    self.update_attributes(:destination_id => g.id)
  end

  def apply_transformation(g)
    adjustment_coefficient_record = AdjustmentCoefficientRecord.find(adjustment_coefficient_record_id)
    g.profiles.each do |x|
      x.players.each do |y|
        y.payoffs.each do |z|
          adjusted = z.payoff
          g.features.each do |f|
            if adjustment_coefficient_record.feature_hash[f.name] != nil
              adjusted += adjustment_coefficient_record.feature_hash[f.name].to_f*(f.feature_samples.where(:sample_id => z.sample_id).first.value - (f.expected_value ? f.expected_value : f.sample_avg))
            end
          end
          z.update_attributes(:payoff => adjusted)
        end
      end
    end
    if g.save!
      return g
    else
      nil
    end
  end
end
