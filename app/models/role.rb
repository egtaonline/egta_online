class Role
  include Mongoid::Document

  embedded_in :role_owner, polymorphic: true

  field :strategies, :type => Array, :default => []  
  field :name
  field :count, type: Integer

  validates_presence_of :name
  validates_uniqueness_of :name
end