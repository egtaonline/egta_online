require 'spec_helper'

describe BackendSimulationCleanup do
  it "calls the backend cleanup with the simulation" do
    Backend.should_receive(:clean_simulation).with(3)
    BackendSimulationCleanup.new.perform(3)
  end
end