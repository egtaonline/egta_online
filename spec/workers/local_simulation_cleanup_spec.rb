require 'spec_helper'

describe LocalSimulationCleanup do
  it "calls the backend cleanup with the simulation" do
    FileUtils.should_receive(:rm_rf).with("#{Rails.root}/tmp/data/3")
    LocalSimulationCleanup.new.perform(3)
  end
end