require 'spec_helper'

describe DataParser do
  describe "with valid data to store in the profile" do
    let!(:yaml_payoff_results) { [Hash["A" => 2000.0, "B" => 1000.0], Hash["A" => 1500.0, "B" => 1200.0]] }
    let!(:yaml_feature_results) { [Hash["Feature1" => 35.0, "Feature2" => 37.0], Hash["Feature1" => 36.0, "Feature2" => 38.0]]}
    let!(:profile) { SymmetricProfile.new }

    before (:each) do
      profile.profile_entries.create!(:name => "A")
      profile.profile_entries.create!(:name => "B")
      DataParser.store_in_profile(profile, yaml_payoff_results, yaml_feature_results)
    end

    it "should add samples to each profile entry" do
      Profile.first.profile_entries.each {|profile_entry| profile_entry.samples.count.should == 2}
    end

    it "should add the correct payoffs" do
      Profile.first.profile_entries.each do |profile_entry|
        profile_entry.samples.each_index { |i| profile_entry.samples[i].payoff.should == yaml_payoff_results[i][profile_entry.name] }
      end
    end

    it "should add the features to the profile" do
      Profile.first.features.count.should == 2
    end

    it "should add samples to the features" do
      Profile.first.features.each {|feature| feature.samples.count.should == 2}
    end
  end
  describe "can fill a profile from a folder number" do
    describe "folder is valid" do
      let!(:profile) { SymmetricProfile.new }
      let!(:yaml_thing) do
        [Hash["BayesianPricing:noRA:0.0" => 3184.82915243534, "AmbiguityAversePricing:noRA:0.0" => 2954.51719611388], 
          Hash["BayesianPricing:noRA:0.0" => 3184.82915243534, "AmbiguityAversePricing:noRA:0.0" => 2954.51719611388],
          Hash["BayesianPricing:noRA:0.0" => 3184.82915243534, "AmbiguityAversePricing:noRA:0.0" => 2954.51719611388],
          Hash["BayesianPricing:noRA:0.0" => 3184.82915243534, "AmbiguityAversePricing:noRA:0.0" => 2954.51719611388],
          Hash["BayesianPricing:noRA:0.0" => 3184.82915243534, "AmbiguityAversePricing:noRA:0.0" => 2954.51719611388],
          Hash["BayesianPricing:noRA:0.0" => 3184.82915243534, "AmbiguityAversePricing:noRA:0.0" => 2954.51719611388]]
      end
      let!(:other_yaml_thing) do
        [Hash["average_dividend" => 0.5, "average_payoff" => 3005.87343125393],
          Hash["average_dividend" => 0.5, "average_payoff" => 3005.87343125393],
          Hash["average_dividend" => 0.5, "average_payoff" => 3005.87343125393],
          Hash["average_dividend" => 0.5, "average_payoff" => 3005.87343125393],
          Hash["average_dividend" => 0.5, "average_payoff" => 3005.87343125393],
          Hash["average_dividend" => 0.5, "average_payoff" => 3005.87343125393]]
      end
        
      before do
        profile.profile_entries.create!(:name => "BayesianPricing:noRA:0.0")
        profile.profile_entries.create!(:name => "AmbiguityAversePricing:noRA:0.0")
        simulation_criteria = double()
        Simulation.stub(:where).with(:number => 41352).and_return(simulation_criteria)
        simulation_criteria.stub_chain(:first, :profile).and_return(profile)
      end
      it "should find invoke store on the correct profile" do
        DataParser.should_receive(:store_in_profile).with(profile, yaml_thing, other_yaml_thing)
        DataParser.parse(41352, ROOT_PATH+"/spec/support")
        
      end
    end
  end
end