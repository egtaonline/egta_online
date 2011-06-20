Given /^a user with email "([^"]*)" and password "([^"]*)"$/ do |email, password|
  User.create!(:email => email, :password => password, :password_confirmation => password)
end

Given /^I am signed in$/ do
  Given "a user with email \"test@test.com\" and password \"stuff1\""
  Given "I am on the sign in page"
  Given "I fill in \"test@test.com\" for \"Email\""
  Given "I fill in \"stuff1\" for \"Password\""
  Given "I check \"Remember me\""
  Given "I press \"Sign in\""
end