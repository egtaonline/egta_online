Then /^there should be (\d+) symmetric profiles$/ do |arg1|
  SymmetricProfile.count.should == arg1.to_i
end

Given /^that analysis item belongs to that symmetric profile$/ do
  @symmetric_profile.analysis_items << @analysis_item
  @analysis_item.save!
end

Given /^that symmetric profile has (\d+) sample record$/ do |arg1|
  payoffs = {}
  @symmetric_profile.proto_string.split(", ").uniq.each do |s|
    payoffs[s] = 1
  end
  @symmetric_profile.sample_records.create!(feature_hash: {}, payoffs: payoffs)
end