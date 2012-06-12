Fabricator(:simulator) do
  name "epp_sim"
  email 'test@test.com'
  version {Fabricate.sequence(:version, 1) {|i| "test#{i}"}}
  configuration { {"Parm1"=>"2","Parm2"=>"3"} }
end

Fabricator(:simulator_with_strategies, from: :simulator) do
  after_create do |sim|
    sim.add_strategy("All", "A")
    sim.add_strategy("All", "B")
  end
end

Fabricator(:simulator_realistic, :from => :simulator) do
  name "epp_sim"
  version "test"
  email 'test@test.com'
  simulator_source File.new("#{Rails.root}/features/support/epp_sim.zip")
end