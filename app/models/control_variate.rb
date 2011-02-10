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
    destination_id = transform_game(game, ":cv").id
    self.save!
  end

  def apply_transformation(game)
    adjustment_coefficient_record = game.simulator.adjustment_coefficient_records.find(adjustment_coefficient_record_id)
    game.profiles.each do |x|
      x.players.each do |y|
        y.payoffs.each do |z|
          adjusted = z.payoff
          game.features.each do |f|
            if adjustment_coefficient_record.feature_hash[f.name] != nil
              adjusted += adjustment_coefficient_record.feature_hash[z.name].to_f*(f.feature_samples.where(:sample_id => z.sample_id).first.value - f.expected_value)
            end
          end
          z.update_attributes(:payoff => adjusted)
        end
      end
    end
  end

  def perform_adjustments
    Stalker.enqueue 'apply_cv', :control_variate => self.id
  end

  def calculate_adjustment_coefficients
    Stalker.enqueue 'calculate_adjustment_coefficients', :control_variate => self.id
  end

  def calculate

  end
end
