class Analyzable
  include Mongoid::Document
#  include Mongoid::Timestamps::Updated
  has_many :analysis_items, :inverse_of => :analyzable
end