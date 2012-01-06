Feature: Game creation uses ajax
  In order to present a dynamic game creation interface
  As a developer
  I want ajax controls to work

Background:
  Given I am signed in

@javascript
Scenario: Selecting a simulator changes the search parameters
  Given the following simulators:
    | name  | version | parameter_hash |
    | testA | alpha   | {a: 2, b: 1}   |
    | testB | beta    | {a: 3, c: 4}   |
  When I am on the new game page
  Then the "A" field should contain "2"
  And the "B" field should contain "1"
  When I select "testB-beta" from "Simulator"
  Then the "C" field should contain "4"
  Then the "A" field should contain "3"

Scenario: Creating a game finds existing profiles
  Given the following simulator:
    | parameter_hash | {a: "2"} |
    | name           | test     |
    | version        | test     |
  And that simulator has 1 role
  And that role has the strategies "A" and "B"
  And that simulator has the following profile:
    | proto_string   | All: 1, 1 |
    | parameter_hash | {a: "2"}  |
  And that profile has 1 sample record
  Given that simulator has the following profiles:
    | proto_string | parameter_hash |
    | All: 1, 2    | {a: "2"}       |
    | All: 2, 2    | {a: "2"}       |
  When I am on the new game page
  And I fill in the following:
    | Name      | test |
    | Game size | 2    |
  And I press "Create Game"
  Then I should be on the last game's page
  And the last game should have 3 profiles
	When I select "All" from "role"
	And I fill in "role_count" with "2"
  And I press "Add Role"
  And I should see "All"
	When I select "A" from "All_strategy"
	And I press "Add Strategy"
	Then I am on the last game's page
  And I should see "All"
	And I should see "A"
	And that game should have a role named "All" with the strategy array "['A']"
	When I select "B" from "All_strategy"
	And I press "Add Strategy"
	Then I should be on the last game's page
	And the last game should have 3 profiles
	Then that game should have a role named "All" with the strategy array "['A', 'B']"
  When I am on the games page
  Then I should see the following table rows:
    | Name | Simulator | Size |
    | test | test-test | 2    |