Feature: Creating a game from scheduler
  In order to easily create games from schedulers
  As a user
  I want a button on the scheduler page to make a game.

Scenario: A scheduler exists that I want to create a game from
  Given I am signed in
  And 1 game scheduler
  And I am on the last game scheduler's page
  When I follow "Create Game to Match"
  Then I should be on the last game's page
  And that game should match the game scheduler
