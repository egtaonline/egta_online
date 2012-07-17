require 'spec_helper'
require "#{Rails.root}/lib/backend/simulation_prep_service"

describe SimulationPrepService do
  describe '#cleanup' do
    it 'removes the files from previous rounds of scheduling' do
      FileUtils.should_receive(:rm_rf).with(Dir["#{Rails.root}/tmp/simulations/*"])
      subject.cleanup
    end
  end
  
  describe '#prepare_simulation' do
    let(:simulation){ double(number: 23) }
    
    it "prepares the simulation for scheduling" do
      FileUtils.should_receive(:mkdir).with("#{Rails.root}/tmp/simulations/#{simulation.number}")
      SpecGenerator.should_receive(:generate).with(simulation, "#{Rails.root}/tmp/simulations")
      Backend.should_receive(:prepare_simulation).with(simulation, "#{Rails.root}/tmp/simulations")
      subject.prepare_simulation(simulation)
    end
  end
end