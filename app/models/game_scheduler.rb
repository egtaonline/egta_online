# A game scheduler automaticallly creates Simulation jobs for a given Game
# instance

class GameScheduler
  include Mongoid::Document

  referenced_in :game, :inverse_of => :game_schedulers
  field :pbs_generator_id
  field :active, :type => Boolean

  scope :active, where(:active=>true)

  field :samples_per_simulation, :type => Integer
  validates_numericality_of :samples_per_simulation, :only_integer=>true, :greater_than=>0
  field :max_samples, :type => Integer
  validates_numericality_of :max_samples, :only_integer=>true

  # Schedule a Simulation for a given Game
  def schedule(n=1)
    1.upto n do
      account = find_account
      scheduled_profile = find_profile if account

      if scheduled_profile
        puts scheduled_profile.id
        simulation = Simulation.new
        simulation.account = account
        simulation.pbs_generator_id = pbs_generator_id
        simulation.size = self.samples_per_simulation
        if account.flux? and game.simulations.where(:flux => true, :state => 'queued').count < FLUX_CORES
          simulation.flux = true
        end
        simulation.state = 'pending'
        scheduled_profile.simulations << simulation
        scheduled_profile.game.simulations << simulation
        puts simulation
        simulation.save!
      else
        break
      end
    end
  end

  private

  def find_account
    account = nil
    Account.all.each do |a|
      if a.schedulable?
        account = a
        break
      end
    end

    account
  end

  def find_profile
    scheduled_profile = nil
    game.profiles.each do |profile|
      if profile.scheduled_count < self.max_samples
        scheduled_profile = profile
        break
      end
    end
    scheduled_profile
  end
end
