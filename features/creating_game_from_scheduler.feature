Feature: Creating game from scheduler

@wip
Scenario: scheduler exists
  Given I am signed in
  Given the following simulator:
    | name           | test   |
    | version        | test   |
    | parameter_hash | {a: 2} |
  And that simulator has the following role:
    | name | All |
  And that simulator has the following profile:
    | proto_string   | All: A, A |
    | parameter_hash | {a: 2}    |
  And that profile has 1 sample record
  And that simulator has the following game scheduler:
    | name           | a=2    |
    | parameter_hash | {a: 2} |
  And I am on the last game scheduler's page
  When I select "All" from "role"
  And I fill in "role_count" with "2"
  And I press "Add Role"
  When I select "A" from "All_strategy"
  And I press "Add Strategy"
  When I select "B" from "All_strategy"
  And I press "Add Strategy"
  And I follow "Create game from scheduler"
  Then I should be on the last game's page
  And show me the page
  And I should see the following table rows:
    | Name      | a=2       |
    | Size      | 2         |
    | Simulator | test-test |
    | A         | 2         |
  And that game should have the role "All" with strategies "A" and "B"
  And that game should have 3 profiles
  And there should be 3 profiles