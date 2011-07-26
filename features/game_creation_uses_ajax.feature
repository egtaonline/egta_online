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
  Then the "A" field should contain "3"
  And the "C" field should contain "4"

@javascript
Scenario: Creating a game with existing profiles finds those profiles
  Given the following simulator:
    | parameter_hash | {a: "2"} |
  And that simulator has the strategy array "['A', 'B']"
  And that simulator has the following symmetric profile:
    | proto_string   | A, A   |
    | parameter_hash | {a: "2"} |
  And the profile_entry of that symmetric profile has a sample
  When I am on the new game page
  And I fill in the following:
    | Name      | test |
    | Game size | 2    |
  And I press "Create Game"
  Then I should be on the last game's page
  When I select "A" from "strategy"
  And I press "Add"
  Then I should see the following table rows:
    | Name       | Samples   |
    | A: 2       | 1 sample  |
  When I select "B" from "strategy"
  And I press "Add"
  Then I should see the following table rows:
    | Name       | Samples   |
    | A: 2       | 1 sample  |
    | A: 1, B: 1 | 0 samples |
    | B: 2       | 0 samples |
  When I am on the games page
  Then I should see the following table rows:
    | Name     | Simulator | Size | Percent Sampled |
    | test     | testing0  | 2    | 33              |