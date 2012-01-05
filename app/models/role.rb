class Role
  include Mongoid::Document
  has_and_belongs_to_many :strategies, inverse_of: nil
  embedded_in :role_owner, polymorphic: true
  
  field :name
  field :count, type: Integer
  alias :to_s :name

  validates_presence_of :name
  validates_uniqueness_of :name
  
  def strategy_array
    strategies.only(:name).collect{|s| s.name}
  end
end