Given /^the profile_entry of that symmetric profile has a sample$/ do
  @symmetric_profile.profile_entries.first.samples.create!(:value => 1)
  puts @symmetric_profile.sampled
end

Then /^there should be (\d+) symmetric profiles$/ do |arg1|
  SymmetricProfile.count.should == arg1.to_i
end

Given /^that analysis item belongs to that symmetric profile$/ do
  @symmetric_profile.analysis_items << @analysis_item
  @analysis_item.save!
end
