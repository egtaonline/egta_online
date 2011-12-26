Feature: Creating a game from scheduler
  In order to easily create games from schedulers
  As a user
  I want a button on the scheduler page to make a game.

Scenario: A scheduler exists that I want to create a game from
  Given I am signed in
  And there is a simulator with corresponding game scheduler
  And I am on the last game scheduler's page
  When I follow "Create game from scheduler"
  Then I should be on the last game's page
  And that game should match the game scheduler
