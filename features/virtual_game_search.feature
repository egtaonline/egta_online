Feature: Virtual game search
  In order to have greater flexibility
  As an analyst
  I want game search to produce a page for the game's virtual record

Background:
  Given 1 user
  And I am on the sign in page
  And I fill in the following:
    | Email    | test1@test.com |
    | Password | password1        |
  And I check "Remember me"
  And I press "Sign in"

Scenario: Creating a virtual game from 1 profile
  Given 1 simulator
  And that simulator has the following profile:
    | proto_string | A, A |
  And I am on the games page
  When I select "a: 2" from "Run time configuration"
  And I press "View game"
  Then I should be on the show game page
  And I should see the following table rows:
    | Run time configuration | a: 2      |
    | A: 2                   | 0 samples |

Scenario: Creating a virtual game from 2 profiles
  Given 1 simulator
  And that simulator has the following profiles:
    | proto_string |
    | A, A         |
    | B, B         |
  And I am on the games page
  When I select "a: 2" from "Run time configuration"
  And I press "View game"
  Then I should be on the show game page
  And I should see the following table rows:
    | Run time configuration | a: 2        |
    | A: 2                   | 0 samples   |
    | B: 2                   | 0 samples   |

Scenario: Creating a virtual game from 3 profiles, excluding 1
  Given 1 simulator
  And that simulator has the following profiles:
    | proto_string |
    | A, A         |
    | A, B         |
    | B, B         |
  And that simulator has the following run time configuration:
    | parameters | {a: 1, b: 2} |
  And the second profile belongs to that run time configuration
  And I am on the games page
  When I select "a: 2" from "Run time configuration"
  And I press "View game"
  Then I should be on the show game page
  And I should see the following table rows:
    | Run time configuration | a: 2        |
    | A: 2                   | 0 samples   |
    | B: 2                   | 0 samples   |