Feature: Removing roles remove profiles

Scenario: GameScheduler
  Given I am signed in
  And 1 game scheduler
  And I am on the last simulator's page
  When I fill in "role" with "All"
  And I press "Add Role"
  And I fill in "All_strategy" with "A"
  And I press "Add Strategy"
  And I am on the last game scheduler's page
  When I select "All" from "role"
  And I fill in "role_count" with "2"
  And I press "Add Role"
  When I select "A" from "All_strategy"
  And I press "Add Strategy"
  Then I should see "All: 2 A"
  When I follow "Remove Role"
  Then I should not see "All: 2 A"