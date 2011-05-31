# A game scheduler automaticallly creates Simulation jobs for a given Game
# instance

class GameScheduler < Scheduler
  include Mongoid::Document
  include StrategyManipulation

  field :size, :type => Integer
  field :strategy_array, :type => Array, :default => []
  has_and_belongs_to_many :profiles


  # Schedule a Simulation for a given Game
  def schedule(n=1)
    account = find_account
    scheduled_profiles = account ? find_profile(n) : []
    scheduled_profiles.each do |profile|
      account = find_account
      if account != nil
        @simulation = profile.simulations.create!(
          :account => account,
          :size => samples_per_simulation,
          :state => 'pending',
          :flux => (simulations.where(:flux => true, :state => 'queued').count < FLUX_CORES))
        simulations << @simulation
        @simulation.save!
      else
        break
      end
    end
  end

  def ensure_profiles
    strategy_array.repeated_combination(size).each do |prototype|
      prototype.sort!
      profile = Profile.find_or_create_by(:simulator_id => simulator.id,
                                          :run_time_configuration_id => run_time_configuration.id,
                                          :proto_string => prototype.join(", "))
      unless self.profiles.include?(profile)
        self.profiles << profile
        profile.save!
      end
    end
  end

  private

  def find_profile(n=1)
    scheduled_profiles = Array.new
    game.profiles.all.each do |profile|
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
