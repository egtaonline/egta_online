Given /^a user with email "([^"]*)" and password "([^"]*)"$/ do |email, password|
  User.create!(:email => email, :password => password, :password_confirmation => password)
end

Given /^I am signed in$/ do
  step "a user with email \"test@test.com\" and password \"stuff1\""
  step "I am on the sign in page"
  step "I fill in \"test@test.com\" for \"Email\""
  step "I fill in \"stuff1\" for \"Password\""
  step "I check \"Remember me\""
  step "I press \"Sign in\""
end