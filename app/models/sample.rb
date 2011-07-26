class Sample
  include Mongoid::Document
  embedded_in :profile_entry
  field :payoff, :type => Float
  alias_attribute :value, :payoff

  validates_presence_of :payoff
  validates_numericality_of :payoff
  after_create :outdate_analysis

  def outdate_analysis
    profile_entry.profile.analysis_items.each {|ai| ai.update_attribute(:outdated, true)}
    profile_entry.profile.games.each {|game| game.analysis_items.each {|ai| ai.update_attribute(:outdated, true)}}
  end
end