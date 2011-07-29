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
  Then I should not see the following table rows:
    | A: 2       | 0 samples |
  When I am on the last symmetric game scheduler's page
  When I select "A" from "strategy"
  And I press "Add"
  Then there should be 1 symmetric profiles
  When I am on the last game's page
  Then I should see the following table rows:
    | Name       | Samples   |
    | A: 2       | 0 samples |

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
  And I am on the last game's page
  And I select "A" from "strategy"
  And I press "Add"
  Then I should not see the following table rows:
    | A: 2       | 0 samples |
  And I am on the first game's page
  And I select "B" from "strategy"
  And I press "Add"
  Then I should not see the following table rows:
    | A: 2       | 0 samples |
  When I am on the last symmetric game scheduler's page
  When I select "A" from "strategy"
  And I press "Add"
  Then there should be 1 symmetric profiles
  When I am on the last game's page
  Then I should not see the following table rows:
    | A: 2       | 0 samples |
  When I am on the first game's page
  Then I should not see the following table rows:
    | A: 2       | 0 samples |

