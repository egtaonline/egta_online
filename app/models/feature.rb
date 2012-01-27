class Feature
  include Mongoid::Document
  embedded_in :game
  field :name
  field :expected_value, :type => Float
  validates_presence_of :name
  validates_uniqueness_of :name
  
  def as_json(options={})
    if options[:root] == true
      {:classPath => "minimal-egat.datatypes.Feature", :object => "#{self.to_json(:root => false)}"}
    else
      {:name => name, :expectedValue => expected_value}
    end
  end
end