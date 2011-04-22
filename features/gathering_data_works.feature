Feature: Gathering data works
  In order to gather data
  As a user
  I want the process to work

@wip
Scenario: Data already exists on remote server
  Given an account
  And a game
  And the game has a simulation
  And the simulation is running and has serial_id 41352
  And the game has a profile
  And the profile references the simulation
  And a server proxy
  And the data exists on the remote server
  When simulations are checked
  Then the folder is downloaded
  And the samples are added to the database
  And the payoffs are added to the profile
  And the features are created
  And the feature samples are added to the features





