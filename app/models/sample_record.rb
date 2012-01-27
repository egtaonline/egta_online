class SampleRecord
  include Mongoid::Document
  embedded_in :profile
  field :payoffs, type: Hash
  field :features, type: Hash
  validates_presence_of :payoffs
  
  def as_json(options={})
    if options[:root] == true
      {:classPath => "minimal-egat.datatypes.ProfileObservation", :object => "#{self.to_json(:root => false)}"}
    else
      {:payoffMap => payoffs, :featureMap => features}
    end
  end
end