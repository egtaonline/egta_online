Feature: Embedding stuff in simulator
  In order to simplify game creation
  As a user
  I want the simulator to embed options for game creation

Background:
  Given a user
  And I am logged in as that user

Scenario: Embedding strategies in simulator
  Given a simulator
  And a game
  And the game references the simulator
  And I am on the show page for the simulator
  When I fill in "strategy" with "Strategy1"
  And I press "Add"
  And I go to the show page for the game
  Then I should see "Strategy1" within "#strategies"