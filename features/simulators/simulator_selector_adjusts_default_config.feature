Feature: Simulator selector adjusts the shown default configuration

@javascript
Scenario Outline: Multiple available simulators on creation
  Given I am signed in
  And two simulators with different default configuration exist
  When I am on the new <class> page
  And I select the first simulator
  Then I should see the default configuration of the first simulator
  When I select the second simulator
  Then I should see the default configuration of the last simulator
  
  Examples:
    | class                            |
    | game                             |
    | game_scheduler                   |
    | hierarchical_scheduler           |
    | deviation_scheduler              |
    | hierarchical_deviation_scheduler |
    | generic_scheduler                |
