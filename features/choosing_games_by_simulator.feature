Feature: Choosing games by simulator
  In order to choose a subset of games
  As a user
  I want a simulator select box and ajax

Background:
  Given a user
  And I am logged in as that user

@wip
@javascript
Scenario: test the simulator select box
  Given 2 simulators
  And the first simulator has 1 game
  And the second simulator has 3 games
  And I am on the games page
  When I select the second simulator from the select menu
  Then I should see the second simulator's games

@wip
@javascript
Scenario: test the simulator select box again
  Given 2 simulators
  And the first simulator has 1 game
  And the second simulator has 3 games
  And I am on the games page
  When I select the first simulator from the select menu
  Then I should see the first simulator's games

