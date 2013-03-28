class MoveProfilesToSimulatorInstances < Mongoid::Migration
  class ::Simulator
    has_many :profiles
  end

  class ::Profile
    belongs_to :simulator
    field :configuration, type: Hash
  end

  def self.up
    Simulator.all.each do |simulator|
      flag = false
      simulator.profiles.distinct(:configuration).each do |config|
        simulator_instance = SimulatorInstance.find_or_create_by(simulator_id: simulator.id, configuration: config)
        puts 'setting id on profiles'
        simulator.profiles.where(configuration: config).set(:simulator_instance_id, simulator_instance.id)
        puts 'setting profile ids on simulator instance'
        simulator_instance.set(:profile_ids, simulator.profiles.where(configuration: config).pluck(:_id))
        puts simulator_instance.reload.profiles.count
        puts simulator.profiles.where(configuration: config).count
        puts 'checking for success'
        if simulator.profiles.where(configuration: config).count != simulator_instance.reload.profiles.count
          puts "failed #{simulator.fullname} #{simulator_instance.id}"
          flag = true
        end
      end
      if flag == false
        profiles = simulator.profiles
        profiles.unset(:simulator_id)
        simulator.unset(:profile_ids)
      end
    end
  end

  def self.down
  end
end