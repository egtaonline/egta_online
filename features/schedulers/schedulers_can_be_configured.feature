Feature: Schedulers can be configured

Scenario Outline: Creating a new scheduler
  Given I am signed in
  And a simulator exists
  When I configure a new <class> at creation
  Then I should see the configured values on that scheduler

  Examples:
  | class                            |
  | game_scheduler                   |
  | hierarchical_scheduler           |
  | deviation_scheduler              |
  | hierarchical_deviation_scheduler |
  | generic_scheduler                |

Scenario Outline: Editing an existing scheduler
  Given I am signed in
  And a <class> exists
  When I edit the configuration of the <class>
  Then I should see the configured values on that scheduler

  Examples:
  | class                            |
  | game_scheduler                   |
  | hierarchical_scheduler           |
  | deviation_scheduler              |
  | hierarchical_deviation_scheduler |
  | generic_scheduler                |
