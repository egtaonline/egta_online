Then /^there should be (\d+) profiles$/ do |arg1|
  Profile.count.should == arg1.to_i
end

Given /^that profile has (\d+) sample record$/ do |arg1|
  @profile = Profile.last
  payoffs = {}
  @profile.name.split("; ").each do |r|
    rpayoffs = {}
    r.split(": ")[1].split(", ").each do |s|
      rpayoffs[s.split(" ")[1]] = 1
    end
    payoffs[r] = rpayoffs
  end
  
  @profile.sample_records.create!(features: {}, payoffs: payoffs)
end