Feature: Schedulers page links to the correct things
  In order to utilize STI in the interface
  As a user
  I want to be able to create multiple types of schedulers from the scheduler page

Background:
  Given 1 user
  And I am on the sign in page
  And I fill in the following:
    | Email    | test@test.com |
    | Password | stuff1        |
  And I check "Remember me"
  And I press "Sign in"

Scenario: Visiting the schedulers index page shows links for creating new schedulers
  Given I am on the schedulers page
  And 1 simulator
  When I follow "New Game Scheduler"
  Then I am on the new game scheduler page





