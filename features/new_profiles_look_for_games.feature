Feature: New profiles look for games
  In order to efficiently assign profiles to games
  As a db admin
  I want profiles to be assigned to relevant games on creation

Scenario: 1 game exists
  Given I am signed in
  Given the following simulator:
    | parameter_hash | {a: 2} |
  And that simulator has the strategy array "['A', 'B']"
  And that simulator has the following symmetric game scheduler:
    | parameter_hash | {a: 2} |
  And the following game:
    | size           | 2      |
    | parameter_hash | {a: 2} |
  And I am on the last symmetric game scheduler's page
  When I select "A" from "strategy"
  And I press "Add"
  And I am on the last game's page
  And I select "A" from "strategy"
  And I press "Add"
  Then there should be 1 symmetric profiles
  And I should be on the last game's page
  And I should see the following table rows:
    | Name       | Samples   |
    | A: 2       | 0 samples |

