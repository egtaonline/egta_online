# Manages control variables
class CvManager
  include Mongoid::Document
  embedded_in :adjustable, :polymorphic => true
  embeds_many :features
  
  def remove_feature(feature_id)
    self.features.where(:_id => feature_id).destroy_all
  end
end