Feature: Games can find their profiles

@javascript
Scenario: Matching profiles already exist
  Given I am signed in
  And a fleshed out simulator with sampled profiles
  And a game that matches those profiles
  When I visit that game's page
  And add the strategies of those profiles to the game
  And I request a representation of the game
  Then I should those profiles




  
