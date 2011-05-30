# A game scheduler automaticallly creates Simulation jobs for a given Game
# instance

class GameScheduler < Scheduler
  include Mongoid::Document
  include StrategyManipulation

  field :size, :type => Integer
  field :strategy_array, :type => Array, :default => []

  has_many :profiles, :as => :schedulable

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

    p = Array.new(self.size, 0)
    while p != nil
      p_strategy_array = p.collect {|i| strategy_array[i]}
      p_strategy_array.sort!
      profile = profiles.detect {|x| x.strategy_array == p_strategy_array}
      unless profile
        prof = SymmetricProfile.new
        p_strategy_array.each do |strategy|
          if prof[strategy] == nil
            prof[strategy] = 1
            prof.profile_entries.create!(:name => strategy)
          else
            prof[strategy] += 1
          end
        end
        self.profiles << prof
        prof.save!
      end

      p = next_profile(p, strategy_array.length, self.size)
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

  def next_profile(array, n_strategy_array, profile_size)
    if array.nil? || array.empty?
      nil
    elsif array.last == (n_strategy_array - 1)
      next_profile(array[0..-2], n_strategy_array, profile_size)
    else
      a = array.clone
      a[-1] += 1
      a.concat(Array.new(profile_size - a.length, a[-1]))
      a
    end
  end
end
