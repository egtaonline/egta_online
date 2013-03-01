require 'spec_helper'
require "#{Rails.root}/lib/backend/simulation_prep_service"

describe SimulationPrepService do
  describe '#prepare_simulation' do
    let(:simulation){ double(_id: 23, id: 23) }

    it "prepares the simulation for scheduling" do
      FileUtils.should_receive(:mkdir).with("#{Rails.root}/tmp/simulations/#{simulation.id}")
      SpecGenerator.should_receive(:generate).with(simulation, "#{Rails.root}/tmp/simulations")
      Backend.should_receive(:prepare_simulation).with(simulation)
      SimulationPrepService.new("#{Rails.root}/tmp/simulations").prepare_simulation(simulation)
    end
  end
end