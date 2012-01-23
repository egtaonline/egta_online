class SampleRecord
  include Mongoid::Document
  embedded_in :profile
  field :payoffs, type: Hash
  field :features, type: Hash
  validates_presence_of :payoffs
  
  def payoff_map
    new_hash = {}
    payoffs.each_pair do |key, value|
      role_hash = {}
      value.each do |subkey, subvalue|
        role_hash[::Strategy.where(:name => subkey).first.as_json(:only => [:name, :number])] = subvalue
      end
      new_hash[profile.role_instances.where(:name => key).first.as_json] = role_hash
    end
  end
  
  def feature_map
    
  end
end