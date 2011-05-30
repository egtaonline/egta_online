Feature: Game scheduler works
  In order to transition to virtual games
  As a developer
  I want schedulers to take on the responsibility of creating profiles

Background:
  Given 1 user
  And I am on the sign in page
  And I fill in the following:
    | Email    | test@test.com |
    | Password | stuff1        |
  And I check "Remember me"
  And I press "Sign in"

Scenario: Profile generation works for single strategy
  Given the following game scheduler:
    | size | 2 |
  And the following run time configuration:
    | parameters | {a: 1, b: 2} |
  And that game scheduler belongs to that run time configuration
  And 1 simulator
  And that simulator has the strategy array "['A']"
  And that game scheduler belongs to that simulator
  And I am on that game scheduler show page
  When I select "A" from "strategy"
  And I press "Add"
  Then I should be on that game scheduler show page
  And I should see the following table rows:
    | Name | Samples   |
    | A: 2 | 0 samples |
