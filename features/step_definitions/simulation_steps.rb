Given /^3 simulations exist$/ do
  @objects = [Fabricate(:simulation, state: 'queued'), Fabricate(:simulation, state: 'failed'), Fabricate(:simulation, state: 'running')]
end

Then /^I should see the simulations in the default order$/ do
  step 'I should see the following table rows:', table("| #{@objects.collect{ |o| o.state }.join(" |\n| ")} |")
end