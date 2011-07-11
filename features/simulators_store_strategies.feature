Feature: Simulators store strategies
  In order to simplify adding strategies to schedulers
  As a user
  I want simulators to store strategies

Background:
  Given I am signed in

Scenario: Simulator has no strategies
  Given 1 simulator
  And I am on the last simulator's page
  When I fill in "strategy" with "ABC"
  And I press "Add"
  Then I am on the last simulator's page
  And I should see "ABC"



