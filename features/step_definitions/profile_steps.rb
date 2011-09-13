Then /^there should be (\d+) profiles$/ do |arg1|
  Profile.count.should == arg1.to_i
end

Given /^that analysis item belongs to that symmetric profile$/ do
  @symmetric_profile.analysis_items << @analysis_item
  @analysis_item.save!
end

Given /^that profile has (\d+) sample record$/ do |arg1|
  payoffs = {}
  @profile.proto_string.split("; ").each do |r|
    rpayoffs = {}
    r.split(": ")[1].split(", ").uniq.each do |s|
      rpayoffs[s] = 1
    end
    payoffs[r] = rpayoffs
  end
  
  @profile.sample_records.create!(features: {}, payoffs: payoffs)
end