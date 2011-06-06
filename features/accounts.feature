Feature: Manage accounts
  In order to submit jobs to nyx/flux
  As a testbed user
  I want to set up my nyx/flux account

# Before do
#   Given 1 user
#   And I am on the sign in page
#   And I fill in the following:
#     | Email    | test1@test.com |
#     | Password | stuff1        |
#   And I check "Remember me"
#   And I press "Sign in"
# end

Background:
  Given a user with email "test@test.com" and password "password"
  And I am on the sign in page
  And I fill in the following:
  | Email    | test@test.com |
  | Password | password        |
  And I check "Remember me"
  And I press "Sign in"

Scenario: Access 'New Account' page
  When I am on the accounts page
  And I follow "New Account"
  Then I should see "New Account"
  And I should see "Username"
  And I should see "Password"
  And I should see "Max concurrent simulations"

Scenario: Create a new account
  When I am on the accounts page
  And I follow "New Account"
  And I fill in "Username" with "dyoon"
  And I fill in "Password" with "dkTkrk5fl"
  And I fill in "Max concurrent simulations" with "50"
  And I press "Create Account"
  Then I should see "Account was successfully created."
  # When I follow "New Account"
  # And I fill in "Username" with "dyoon"
  
Scenario: Fails to create a new account with incorrect password
  When I am on the accounts page
  And I follow "New Account"
  And I fill in "Username" with "dyoon"
  And I fill in "Password" with "adfasdf"
  And I fill in "Max concurrent simulations" with "50"
  And I press "Create Account"
  Then I should not see "Account was successfully created."
  
Scenario: Fails to create a new account with empty password
  When I am on the accounts page
  And I follow "New Account"
  And I fill in "Username" with "dyoon"
  And I fill in "Max concurrent simulations" with "50"
  And I press "Create Account"
  Then I should not see "Account was successfully created."
  
Scenario: Fails to create a new account with empty max concurrent simulations
  When I am on the accounts page
  And I follow "New Account"
  And I fill in "Username" with "dyoon"
  And I fill in "Password" with "dkTkrk5fl"
  And I press "Create Account"
  Then I should not see "Account was successfully created."
  
Scenario: Fails to create a new account with non-numeric value for max concurrent simulations
  When I am on the accounts page
  And I follow "New Account"
  And I fill in "Username" with "dyoon"
  And I fill in "Password" with "dkTkrk5fl"
  And I fill in "Max concurrent simulations" with "a12f"
  And I press "Create Account"
  Then I should not see "Account was successfully created."