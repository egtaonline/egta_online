class Strategy
  include Mongoid::Document
  include Mongoid::Sequence
  field :name
  field :number, :type=>Integer
  index :name
  index :number
  sequence :number
  validates_presence_of :name
  validates_uniqueness_of :name
  
  default_scope order_by(:name, :asc)
  
  def as_json(options={})
    if options[:root] == true
      {:classPath => "minimal-egat.datatypes.Action", :object => "#{self.to_json(:root => false)}"}
    else
      {:number => number, :name => name}
    end
  end
end