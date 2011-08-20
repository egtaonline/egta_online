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
Scenario: Creating a game finds existing profiles
  Given the following simulator:
    | parameter_hash | {a: "2"} |
    | name           | test     |
    | version        | test     |
  And that simulator has the strategy array "['A', 'B']"
  And that simulator has the following symmetric profile:
    | proto_string   | A, A   |
    | parameter_hash | {a: "2"} |
  And the profile_entry of that symmetric profile has a sample
  Then that symmetric profile should have 1 sample
  Given that simulator has the following symmetric profiles:
    | proto_string | parameter_hash |
    | A, B         | {a: "2"}       |
    | B, B         | {a: "2"}       |
  When I am on the new game page
  And I fill in the following:
    | Name      | test |
    | Game size | 2    |
  And I press "Create Game"
  Then I should be on the last game's page
  And the last game should have 3 profiles
  When I select "A" from "strategy"
  And I press "Add"
  And I select "B" from "strategy"
  And I press "Add"
  When I am on the games page
  And show me the page
  Then I should see the following table rows:
    | Name | Simulator | Size |
    | test | test-test | 2    |