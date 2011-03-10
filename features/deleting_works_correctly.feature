Feature: Deleting works correctly
  In order to maintain sanity
  As a user
  I want deleting to work the way I expect it to

Scenario: Deleting a simulation deletes related feature samples
  Given a Game
  And the Game has a Feature
  And the Feature has a FeatureSample
  And the Game has a Simulation
  And the Simulation has a Sample
  And the Sample is referenced in the FeatureSample
  When I delete the Simulation
  Then the FeatureSample is deleted

Scenario: Deleting a simulation deletes related payoffs
  Given a Game
  And the Game has a Profile
  And the Profile has a Player
  And the Player has a Payoff
  And the Game has a Simulation
  And the Simulation has a Sample
  And the Sample is referenced in the Payoff
  When I delete the Simulation
  Then the Payoff is deleted

Scenario: Deleting a simulator deletes related games
  Given a Simulator
  And a Game
  And the Game references the Simulator
  When I delete the Simulator
  Then the Game is deleted

Scenario: Deleting a game deletes related game schedulers
  Given a Game
  And a GameScheduler
  And the GameScheduler references the Game
  When I delete the Game
  Then the GameScheduler is deleted