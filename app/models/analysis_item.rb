class AnalysisItem
  include Mongoid::Document
  belongs_to :analyzable
  field :type
  field :outdated, :type => Boolean, :default => false
end