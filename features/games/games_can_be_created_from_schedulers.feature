Feature: Games can be created from schedulers

Background:
  Given I am signed in

Scenario Outline: Creating a game from a scheduler with roles and strategies
  Given a <class> with sampled profiles
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
  | dpr_game_scheduler               |
  | dpr_deviation_scheduler          |

Scenario Outline: Creating a game from a deviation scheduler adds the deviating strategy
  Given a fleshed out simulator with an empty <class>
  And that scheduler has target and deviating strategies
  When I visit that scheduler's page
  And I follow "Create Game to Match"
  Then I should see a game with all the specified strategies

  Examples:
  | class                            |
  | deviation_scheduler              |
  | hierarchical_deviation_scheduler |
  | dpr_deviation_scheduler          |