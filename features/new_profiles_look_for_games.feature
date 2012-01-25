Feature: New profiles look for games
  In order to efficiently assign profiles to games
  As a db admin
  I want profiles to be assigned to relevant games on creation

Scenario: 1 game exists, no prior profiles
  Given I am signed in
  Given the following simulator:
    | parameter_hash | {a: 2} |
  And that simulator has 1 role
  And that role has the strategies "A" and "B"
  And that simulator has the following game scheduler:
		| size					 | 2      |
    | parameter_hash | {a: 2} |
  And that simulator has the following game:
    | size           | 2      |
    | parameter_hash | {a: 2} |
  And I am on the last game's page
	When I select "All" from "role"
	And I fill in "role_count" with "2"
  And I press "Add Role"
  Then I am on the last game's page
  And I should see "All"
	When I select "A" from "All_strategy"
	And I press "Add Strategy"
  When I am on the last game scheduler's page
	When I select "All" from "role"
	And I fill in "role_count" with "2"
  And I press "Add Role"
  When I select "A" from "All_strategy"
  And I press "Add Strategy"
  Then there should be 1 profiles
  And the last game should have 1 profiles

Scenario: 2 games exist, no prior profiles, no matches
  Given I am signed in
  Given the following simulator:
    | parameter_hash | {a: 2} |
  And that simulator has 1 role
  And that role has the strategies "A" and "B"
  And that simulator has the following game scheduler:
    | parameter_hash | {a: 2} |
    | size           | 2      |
  And that simulator has the following games:
    | size | parameter_hash |
    | 2    | {a: 2}         |
    | 2    | {a: 3}         |
  When I am on the last game scheduler's page
  When I select "All" from "role"
	And I fill in "role_count" with "2"
  And I press "Add Role"
  When I select "A" from "All_strategy"
  And I press "Add"
  Then there should be 1 profiles
  And the last game should have 0 profiles
  And the first game should have 1 profiles

Scenario: no prior games, 2 prior profiles exist
  Given I am signed in
  Given the following simulator:
    | parameter_hash | {a: "2"} |
  And that simulator has 1 role
  And that role has the strategies "A" and "B"
  And that simulator has the following profile:
    | proto_string   | All: 1, 2 |
    | parameter_hash | {a: "2"}  |
  And that profile has 1 sample record
  And that simulator has the following profile:
    | proto_string   | All: 1, 1 |
    | parameter_hash | {a: "3"}  |
  When I am on the new game page
  And I fill in the following:
    | Name      | test |
    | Game size | 2    |
  And I press "Create Game"
  Then I should be on the last game's page
  Then the last game should have 1 profiles