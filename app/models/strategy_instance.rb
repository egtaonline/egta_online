class StrategyInstance
  include Mongoid::Document
  embedded_in :role_instance
  
  field :name
  field :count, :type => Integer
  
  validates_uniqueness_of :name
  validates_presence_of :name, :count
end