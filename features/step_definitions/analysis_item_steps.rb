Then /^that analysis item is outdated$/ do
  @analysis_item.outdated.should == true
end
