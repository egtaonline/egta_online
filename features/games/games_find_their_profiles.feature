Feature: Games can find their profiles

@javascript
Scenario: Matching profiles already exist
  Given I am signed in
  And a fleshed out simulator instance with sampled profiles exists
  And a game that matches those profiles exists
  When I visit that game's page
  And add the strategies of those profiles to the game
  And I request a representation of the game
  Then I should have those profiles





