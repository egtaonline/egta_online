Fabricator(:simulator) do
  name "epp_sim"
  version { Fabricate.sequence(:version) { |i| "testing#{i}" } }
  simulator_source { |simulator| uploader = SimulatorUploader.new; uploader.store!(File.open("/Users/bcassell/Ruby/egt_working_directory/epp_sim.zip")); uploader }
  after_create { |simulator| simulator.games << Fabricate.build(:game)}
end