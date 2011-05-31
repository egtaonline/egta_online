Given /^the profile_entry of that profile has a sample$/ do
  @profile.profile_entries.first.samples.create!(:value => 1)
end

Then /^there should be (\d+) profiles$/ do |arg1|
  Profile.count.should == arg1.to_i
end