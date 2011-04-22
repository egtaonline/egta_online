Feature: Deleting works correctly
  In order to maintain sanity
  As a user
  I want deleting to work the way I expect it to

Scenario: Deleting a simulation deletes related feature samples
  Given a game
  And the game has a feature
  And the feature has a feature sample
  And the game has a simulation
  And the simulation has a sample
  And the sample is referenced in the feature sample
  When I delete the simulation
  Then the feature sample is deleted

Scenario: Deleting a simulation deletes related payoffs
  Given a game
  And the game has a profile
  And the profile has a player
  And the player has a payoff
  And the game has a simulation
  And the simulation has a sample
  And the sample is referenced in the payoff
  When I delete the simulation
  Then the payoff is deleted

Scenario: Deleting a simulator deletes related games
  Given a simulator
  And a game
  And the game references the simulator
  When I delete the simulator
  Then the game is deleted

Scenario: Deleting a game deletes related simulations
  Given a game
  And the game has a simulation
  When I delete the game
  Then the simulation is deleted

Scenario: Deleting a simulator deletes related simulations
  Given a simulator
  And a game
  And the game references the simulator
  And the game has a simulation
  When I delete the simulator
  Then the simulation is deleted
