Then /^there should be (\d+) profiles$/ do |arg1|
  Profile.count.should == arg1.to_i
end