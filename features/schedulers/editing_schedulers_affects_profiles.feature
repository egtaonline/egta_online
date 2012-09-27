Feature: Editing schedulers causes new profiles to be created

Scenario Outline: A scheduler with existing profiles has its configuration edited
  Given I am signed in
  And a fleshed out simulator with a non-empty <class> exists
  When I edit a parameter of that scheduler
  Then new profiles should be created
  And I should see the new parameter value

  Examples:
    | class                            |
    | game_scheduler                   |
    | hierarchical_scheduler           |
    | deviation_scheduler              |
    | hierarchical_deviation_scheduler |
    | dpr_game_scheduler               |
    | dpr_deviation_scheduler          |