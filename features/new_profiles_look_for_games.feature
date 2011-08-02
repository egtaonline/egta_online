Feature: New profiles look for games
  In order to efficiently assign profiles to games
  As a db admin
  I want profiles to be assigned to relevant games on creation

Scenario: 1 game exists, no prior profiles
  Given I am signed in
  Given the following simulator:
    | parameter_hash | {a: 2} |
  And that simulator has the strategy array "['A', 'B']"
  And that simulator has the following symmetric game scheduler:
    | parameter_hash | {a: 2} |
  And the following game:
    | size           | 2      |
    | parameter_hash | {a: 2} |
  And I am on the last game's page
  And I select "A" from "strategy"
  And I press "Add"
  When I am on the last symmetric game scheduler's page
  When I select "A" from "strategy"
  And I press "Add"
  Then there should be 1 symmetric profiles
  And the last game should have 1 profiles

Scenario: 2 games exist, no prior profiles, no matches
  Given I am signed in
  Given the following simulator:
    | parameter_hash | {a: 2} |
  And that simulator has the strategy array "['A', 'B']"
  And that simulator has the following symmetric game scheduler:
    | parameter_hash | {a: 2} |
  And the following games:
    | size | parameter_hash |
    | 2    | {a: 2}         |
    | 2    | {a: 3}         |
  When I am on the last symmetric game scheduler's page
  When I select "A" from "strategy"
  And I press "Add"
  Then there should be 1 symmetric profiles
  And the last game should have 0 profiles

Scenario: no prior games, 2 prior profiles exist
  Given I am signed in
  Given the following simulator:
    | parameter_hash | {a: "2"} |
  And that simulator has the strategy array "['A', 'B']"
  And that simulator has the following symmetric profile:
    | proto_string   | A, B   |
    | parameter_hash | {a: "2"} |
  And the profile_entry of that symmetric profile has a sample
  And that simulator has the following symmetric profile:
    | proto_string   | A, A   |
    | parameter_hash | {a: "3"} |
  When I am on the new game page
  And I fill in the following:
    | Name      | test |
    | Game size | 2    |
  And I press "Create Game"
  Then I should be on the last game's page
  Then the last game should have 1 profiles