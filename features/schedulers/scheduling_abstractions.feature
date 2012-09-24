Feature: Scheduling abstractions generate the correct profiles

Background:
  Given I am signed in

Scenario Outline: Adding a role with valid counts creates the proper reduced role
  Given a fleshed out simulator with an empty <class>
  When I add a role with valid counts
  Then a reduced role should exist on that scheduler

  Examples:
  | class                            |
  | hierarchical_scheduler           |
  | hierarchical_deviation_scheduler |
  | dpr_game_scheduler               |
  | dpr_deviation_scheduler          |

Scenario Outline: Adding a role with invalid counts leads to an error message
  Given a fleshed out simulator with an empty <class>
  When I add a role with invalid counts
  Then a reduced role should not exist on that scheduler
  And I should be on that scheduler's page
  And I should see "Reduced count cannot be larger than full count."

  Examples:
  | class                            |
  | hierarchical_scheduler           |
  | hierarchical_deviation_scheduler |
  | dpr_game_scheduler               |
  | dpr_deviation_scheduler          |
