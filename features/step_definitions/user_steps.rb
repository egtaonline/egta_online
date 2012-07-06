Given /^I have a login$/ do
  @user = Fabricate(:user)
end

Given /^I am signed in$/ do
  step "I have a login"
  step "I am on the sign in page"
  step "I sign in with valid credentials"
  step "I check \"Remember me\""
  step "I press \"Sign in\""
end

Given /^I sign in with valid credentials$/ do
  fill_in 'Email', with: @user.email
  fill_in 'Password', with: @user.password
end

Given /^I sign in with the incorrect password$/ do
  fill_in 'Email', with: @user.email
  fill_in 'Password', with: "#{@user.password}1"
end

Given /^I sign in with an invalid email$/ do
  fill_in 'Email', with: "#{@user.email}1"
  fill_in 'Password', with: @user.password
end