class AnalysisItem
  include Mongoid::Document
  belongs_to :analyzable, :polymorphic => true
  field :type
  field :outdated, :type => Boolean, :default => false
end