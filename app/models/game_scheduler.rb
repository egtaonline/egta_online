class GameScheduler < Scheduler
  include StrategyManipulation

  field :size, :type => Integer
  field :strategy_array, :type => Array, :default => []
  has_and_belongs_to_many :profiles
  validates_presence_of :size

  def schedule(n=1)
    1.upto n do
      scheduled_profile = find_profile
      if scheduled_profile
        simulation = scheduled_profile.simulations.create!(
          :size => samples_per_simulation,
          :state => 'pending',
          :flux => (simulations.where(:flux => true, :state => 'queued').count < FLUX_CORES))
        simulations << simulation
        simulation.save!
      else
        break
      end
    end
  end

  def find_profile
    scheduled_profile = nil
    profiles.each do |profile|
      if profile.scheduled_count < self.max_samples
        scheduled_profile = profile
        break
      end
    end
    scheduled_profile
  end
end