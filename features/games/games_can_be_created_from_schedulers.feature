Feature: Games can be created from schedulers

Scenario Outline: Creating a game from a scheduler with roles and strategies
  Given I am signed in
  And a fleshed out simulator with a non-empty <class> exists
  And its profiles have been sampled
  When I visit that scheduler's page
  And I follow "Create Game to Match"
  Then I should see a game that matches that scheduler
  When I request a representation of the game
  Then I should see all the profiles of the scheduler that have been sampled

  Examples:
  | class                            |
  | game_scheduler                   |
  | hierarchical_scheduler           |
  | deviation_scheduler              |
  | hierarchical_deviation_scheduler |
  | generic_scheduler                |
