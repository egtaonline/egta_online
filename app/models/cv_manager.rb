# Manages control variables
class CvManager
  include Mongoid::Document
  embedded_in :game
  embeds_many :features
  
  def remove_feature(feature_id)
    
  end
end