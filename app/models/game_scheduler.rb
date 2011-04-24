# A game scheduler automaticallly creates Simulation jobs for a given Game
# instance

class GameScheduler < Scheduler
  include Mongoid::Document

  belongs_to :game
  field :active, :type => Boolean
  scope :active, where(:active=>true)
  field :samples_per_simulation, :type => Integer
  field :max_samples, :type => Integer
  validates_numericality_of :samples_per_simulation, :max_samples, :only_integer=>true, :greater_than=>0

  # Schedule a Simulation for a given Game
  def schedule(n=1)
    account = find_account
    scheduled_profiles = account ? find_profile(n) : []
    scheduled_profiles.each do |profile|
      account = find_account
      if account != nil
        @simulation = @game.simulations.create!(:account => account,
          :size => samples_per_simulation,
          :state => 'pending',
          :profile_id => profile.id,
          :flux => (Simulation.where(:game_id => game.id, :flux => true, :state => 'queued').count < FLUX_CORES))
        simulations << @simulation
        @simulation.save!
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

  def find_profile(n=1)
    scheduled_profiles = Array.new
    game.profiles.all.shuffle.each do |profile|
      if profile.scheduled_count < self.max_samples
        scheduled_profiles << profile
        if scheduled_profiles.size >= n
          break
        end
      end
    end
    scheduled_profiles
  end
end
