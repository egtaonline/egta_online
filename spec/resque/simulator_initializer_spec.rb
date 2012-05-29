require 'spec_helper'

describe SimulatorInitializer do
  before(:all) do
    @simulator = Fabricate(:simulator_realistic, :name => "not_epp_sim")
    ResqueSpec.perform_all(:simulator_initializer)
  end
  
  it "should upload the simulator to the server" do
    File.exists?("#{Yetting.deploy_path}/#{@simulator.name}.zip")
  end
  
  it "should unzip the simulator on the server" do
    File.exists?("#{Yetting.deploy_path}/#{@simulator.fullname}")
  end
end