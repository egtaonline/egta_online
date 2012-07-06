Feature: New profiles look for games
  In order to efficiently assign profiles to games
  As a db admin
  I want profiles to be assigned to relevant games on creation

Scenario: 1 game exists, no prior profiles
  Given I am signed in
  And a fleshed out simulator with an empty game_scheduler of size 2 exists
  And that simulator has a game that matches the scheduler
  When I add the role All with size 2 and the strategies Strat1, Strat2 to the scheduler
  Then that game should have 3 profiles

Scenario: 1 non-matching games exist, no prior profiles
  Given I am signed in
  And a fleshed out simulator with an empty game_scheduler of size 2 exists
  And that simulator has a game that does not match the scheduler
  When I add the role All with size 2 and the strategies Strat1, Strat2 to the scheduler
  Then that game should have 0 profiles