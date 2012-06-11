class Configuration
  include Mongoid::Document
  
  belongs_to :configurable, polymorphic: true
  has_many :profiles
  
  field :parameter_hash, type: Hash, default: {}
  
  validates_uniqueness_of :parameter_hash
end