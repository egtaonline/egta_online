Then /^the file "([^"]*)" should exist$/ do |arg1|
  File.exists?(arg1).should == true
end
