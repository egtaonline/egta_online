# A game scheduler automaticallly creates Simulation jobs for a given Game
# instance

class GameScheduler
  include Mongoid::Document

  embedded_in :game
  field :pbs_generator_id

  scope :active, where(:active=>true)
  scope :random, :order=>'RAND()'
  default_scope :order => 'created_at DESC'

  field :samples_per_simulation
  validates_numericality_of :samples_per_simulation, :only_integer=>true, :greater_than=>0
  field :max_samples
  validates_numericality_of :max_samples, :only_integer=>true

  # Schedule a Simulation for a given Game
  def schedule(n=1)
    account = find_account
    1.upto n do
      scheduled_profile = find_profile if account

      simulation = nil
      if scheduled_profile
        simulation = Simulation.new
        simulation.account = account
        simulation.pbs_generator_id = pbs_generator.id
        simulation.size = self.samples_per_simulation
        if account.flux? and Simulation.find_all_by_flux_and_state(true, 'queued').size < FLUX_CORES
          simulation.flux = true
        end
        scheduled_profile.simulations << simulation
        simulation.save!
      else
        break
      end
    end
  end

  private

  def find_account
    account = nil
    Account.all.random.each do |a|
      if a.schedulable?
        account = a
        break
      end
    end

    account
  end

  def find_profile
    scheduled_profile = nil
    game.profiles.random.each do |profile|
      if profile.scheduled_count < self.max_samples
        scheduled_profile = profile
      end
    end
    scheduled_profile
  end
end
