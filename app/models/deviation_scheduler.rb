# A deviation scheduler automatically submit Simulation jobs which perform deviation test
# from a single Profile

class DeviationScheduler
  include Mongoid::Document

  referenced_in :pbs_generator
  referenced_in :game
  field :strategy_id

  scope :active, where(:active=>true)

  field :samples_per_simulation, :type => Integer
  validates_numericality_of :samples_per_simulation, :only_integer=>true, :greater_than=>0
  field :max_samples, :type => Integer
  validates_numericality_of :max_samples, :only_integer=>true

#TODO: fix

#   def schedule
#
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
#   # Find an account that is available to submit jobs.
#   def find_account
#     account = nil
#     Account.all.shuffle.each do |a|
#       if a.schedulable?
#         account = a
#         break
#       end
#     end
#
#     account
#   end
#
#   # Find a single deviated profile from a given profile
#   def find_profile
#     scheduled_profile = nil
#     possible_profiles = find_deviations
#
#     if possible_profiles
#       possible_profiles.shuffle.each do |possible_profile|
#         if possible_profile.payoffs.count < max_samples
#           scheduled_profile = possible_profile
#           break
#         end
#       end
#     end
#     scheduled_profile
#   end
#
#   # Find all possible deviations from a given profile
#   def find_deviations
#     profiles = []
#
#     game.profiles.all.each do |profile|
#
#       game.profiles.find(profile_id).players.each.with_index do |not_relevent, i|
#
#         if strategy_id == profile.players[i].strategy
#             next
#         end
#
#         array_of_strat_ids = []
#         profile.players.each.with_index do |more_relevent, j|
#           array_of_strat_ids[j] = more_relevent.strategy.id
#         end
#
#       array_of_strat_ids[i] = strategy_id
#
#       array_of_strat_ids = array_of_strat_ids.sort
#
#         is_this_a_deviation = true
#         profile.players.each.with_index do |x, j|
#                 if x.strategy_id != array_of_strat_ids[j]
#                   is_this_a_deviation = false
#                   break
#                 end
#         end
#         if is_this_a_deviation
#           profiles << profile
#           break
#         end
#       end
#     end
#
#     profiles
#   end
end


