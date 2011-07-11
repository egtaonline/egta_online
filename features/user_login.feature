Feature: User logs in successfully only with a correct credential
  In order to manage users
  As a tester
  I want to log in only with correct credentials
  
  Scenario: Log in successfully with correct credential
    Given 1 user
    And I am on the sign in page
    When I fill in the following:
      | Email    | test1@test.com |
      | Password | password1        |
    And I check "Remember me"
    And I press "Sign in"
    Then I should be on the home page
    And I should see "Signed in successfully."

  Scenario: Log in successfully with correct credential2
    Given 2 user
    And I am on the sign in page
    When I fill in the following:
      | Email    | test2@test.com |
      | Password | password2        |
    And I check "Remember me"
    And I press "Sign in"
    Then I should be on the home page

  Scenario: Fail to log in with incorrect password
    Given 1 user
    And I am on the sign in page
    When I fill in the following:
      | Email    | test@test.com |
      | Password | stuff123        |
    And I check "Remember me"
    And I press "Sign in"
    Then I should be on the sign in page
    And I should see "Invalid email or password."
  
  Scenario: Fail to log in with invalid email
    Given 1 user
    And I am on the sign in page
    When I fill in the following:
      | Email    | test@notest.com |
      | Password | stuff123        |
    And I check "Remember me"
    And I press "Sign in"
    Then I should be on the sign in page
    And I should see "Invalid email or password."