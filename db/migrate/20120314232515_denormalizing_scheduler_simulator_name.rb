class DenormalizingSchedulerSimulatorName < Mongoid::Migration
  def self.up
    Scheduler.all.each do |s|
      s.update_attribute(:simulator_fullname, s.simulator.fullname)
    end
  end

  def self.down
  end
end