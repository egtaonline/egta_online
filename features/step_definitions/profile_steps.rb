Then /^there should be (\d+) profiles$/ do |arg1|
  Profile.count.should == arg1.to_i
end

Given /^that profile has (\d+) sample record$/ do |arg1|
  @profile = Profile.last
  payoffs = {}
  @profile.proto_string.split("; ").each do |r|
    rpayoffs = {}
    r.split(": ")[1].split(", ").uniq.each do |s|
      s = Strategy.where(:number => s).first.name
      rpayoffs[s] = 1
    end
    payoffs[r] = rpayoffs
  end
  
  @profile.sample_records.create!(features: {}, payoffs: payoffs)
end