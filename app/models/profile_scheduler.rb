# A ProfileScheduler automatically creates Simulation jobs for a single Profile

class ProfileScheduler
  include Mongoid::Document
  field :profile_id
  embedded_in :game
  embeds_one :pbs_generator

  scope :active, where(:active=>true)

  field :samples_per_simulation, :type => Integer
  validates_numericality_of :samples_per_simulation, :only_integer=>true, :greater_than=>0
  field :max_samples, :type => Integer
  validates_numericality_of :max_samples, :only_integer=>true

#TODO:fix
#   def schedule
#     account = find_account
#
#     scheduled_profile = find_profile if account
#
#     simulation = nil
#     if scheduled_profile
#       simulation = Simulation.new
#       simulation.account = account
#       simulation.profile = scheduled_profile
#       simulation.pbs_proxy = self.pbs_proxy
#       simulation.size = self.samples_per_simulation
#       if account.flux? and Simulation.find_all_by_flux_and_state(true, 'queued').size < FLUX_CORES
#         simulation.flux = true
#       end
#       simulation.save
#     end
#
#     simulation
#   end
#
#   private
#
#   def find_account
#     account = nil
#     #Account.all(:order=> 'RAND()').each do |a|
#     #Account.all.shuffle.each do |a| # SQLite3 does not support RAND() op.
#     Account.all.each do |a| # SQLite3 does not support RAND() op. #this is only a fix for kevin's stupid computer use the line above this in any real environment
#
#       if a.schedulable?
#         account = a
#         break
#       end
#     end
#
#     account
#   end
#
#   def find_profile
#     scheduled_profile = nil
#
#     #game.profiles.random.each do |profile|
#       if profile.players.first.payoffs.count < self.max_samples
#            scheduled_profile = profile
#      #     break
#       end
#     #end
#
#     scheduled_profile
#   end
end
