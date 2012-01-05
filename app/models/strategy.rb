class Strategy
  include Mongoid::Document
  include Mongoid::Sequence
  field :name
  field :number, :type=>Integer
  sequence :number
  validates_presence_of :name
  validates_uniqueness_of :name
end