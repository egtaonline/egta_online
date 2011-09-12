Feature: Schedulers create profiles
  In order to keep profiles modular
  As a db-admin
  I want schedulers to be responsible for creating profiles

Scenario: Profile already exists with the same configuration
  Given I am signed in
  Given the following simulator:
    | parameter_hash | {a: 2} |
  And that simulator has the strategy array "['A', 'B']"
  And that simulator has the following symmetric profile:
    | proto_string   | A, A   |
    | parameter_hash | {a: 2} |
  And that symmetric profile has 1 sample record
  And that simulator has the following symmetric game scheduler:
    | parameter_hash | {a: 2} |
  And I am on the last symmetric game scheduler's page
  When I select "A" from "strategy"
  And I press "Add"
  When I select "B" from "strategy"
  And I press "Add"
  And show me the page
  Then there should be 3 symmetric profiles
