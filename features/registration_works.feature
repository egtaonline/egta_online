Feature: Registration works
  In order to access to the web page
  As a new user
  I want to be able to register properly

Scenario: New user
  Given I am not authenticated
  When I go to the home page
  Then I should be on the users sign in page

Scenario Outline: Creating a new account
	Given I am not authenticated
	When I go to register # define this path mapping in features/support/paths.rb, usually as '/users/sign_up'
	And I fill in "user_email" with "<email>"
	And I fill in "user_password" with "<password>"
	And I fill in "user_password_confirmation" with "<password>"
	And I press "Sign up"
	Then I should see "logged in as <email>"

  Examples:
    | email           | password   |
    | testing@man.net | secretpass |
    | foo@bar.com     | fr33z3     |