Feature: Schedulers create profiles
  In order to keep profiles modular
  As a db-admin
  I want schedulers to be responsible for creating profiles

Scenario: Profile already exists with the same configuration
  Given I am signed in
  Given the following simulator:
    | parameter_hash | {a: 2} |
  And that simulator has the strategy array "['A', 'B']"
  And that simulator has the following profile:
    | proto_string   | All: A, A   |
    | parameter_hash | {a: 2}      |
  And that profile has 1 sample record
  And that simulator has the following game scheduler:
    | parameter_hash | {a: 2} |
    | size           | 2      |
  And I am on the last game scheduler's page
  When I select "All" from "role"
  And I fill in "role_count" with "2"
  And I press "Add Role"
  When I select "A" from "All_strategy"
  And I press "Add Strategy"
  When I select "B" from "All_strategy"
  And I press "Add Strategy"
  And show me the page
  Then there should be 3 profiles
