Feature: Virtual game search
  In order to have greater flexibility
  As an analyst
  I want game search to produce a page for the game's virtual record

Background:
  Given 1 user
  And I am on the sign in page
  And I fill in the following:
    | Email    | test@test.com |
    | Password | stuff1        |
  And I check "Remember me"
  And I press "Sign in"

Scenario: Creating a virtual game from 1 profile
  Given 1 simulator
  And 1 profile
  And that profile has the following profile_entry:
    | name       | A: 2 |
  And that profile belongs to that simulator
  And the following run time configuration:
    | parameters | {a: 1, b: -1} |
  And that profile belongs to that run time configuration
  And I am on the games page
  When I select "a: 1, b: -1" from "Run time configuration"
  And I press "View game"
  Then I should be on the show game page
  And I should see the following table rows:
    | Run time configuration | a: 1, b: -1 |
    | A: 2                   | 0 samples   |

Scenario: Creating a virtual game from 2 profiles
  Given 1 simulator
  And 1 profile
  And that profile has the following profile_entry:
    | name       | A: 2 |
  And that profile belongs to that simulator
  And the following run time configuration:
    | parameters | {a: 1, b: -1} |
  And that profile belongs to that run time configuration
  And 1 profile
  And that profile has the following profile_entry:
    | name       | B: 2 |
  And that profile belongs to that simulator
  And that profile belongs to that run time configuration
  And I am on the games page
  When I select "a: 1, b: -1" from "Run time configuration"
  And I press "View game"
  Then I should be on the show game page
  And I should see the following table rows:
    | Run time configuration | a: 1, b: -1 |
    | A: 2                   | 0 samples   |
    | B: 2                   | 0 samples   |

Scenario: Creating a virtual game from 3 profiles, excluding 1
  Given 1 simulator
  And 1 profile
  And that profile has the following profile_entry:
    | name       | A: 1, B: 1 |
  And that profile belongs to that simulator
  And the following run time configuration:
    | parameters | {a: 1, b: 1} |
  And that profile belongs to that run time configuration
  And 1 profile
  And that profile has the following profile_entry:
    | name       | A: 2 |
  And that profile belongs to that simulator
  And the following run time configuration:
    | parameters | {a: 1, b: -1} |
  And that profile belongs to that run time configuration
  And 1 profile
  And that profile has the following profile_entry:
    | name       | B: 2 |
  And that profile belongs to that simulator
  And that profile belongs to that run time configuration
  And I am on the games page
  When I select "a: 1, b: -1" from "Run time configuration"
  And I press "View game"
  Then I should be on the show game page
  And I should see the following table rows:
    | Run time configuration | a: 1, b: -1 |
    | A: 2                   | 0 samples   |
    | B: 2                   | 0 samples   |