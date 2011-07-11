Given /^the profile_entry of that symmetric profile has a sample$/ do
  @symmetric_profile.profile_entries.first.samples.create!(:value => 1)
end

Then /^there should be (\d+) symmetric profiles$/ do |arg1|
  SymmetricProfile.count.should == arg1.to_i
end