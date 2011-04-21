Feature: Deleting simulation removes payoffs
  In order to maintain consistency in the database
  As a admin
  I want deleting a simulation to remove payoffs associated with its samples

Scenario: Deleting a simulation
  Given a profile with a simulation with a single sample
  When I delete the simulation
  Then no players in the profile will have payoffs that reference that sample

Scenario: Deleting a simulation
	Given a profile with a simulation with a single sample
	When I delete the sample
	Then no players in the profile will have payoffs that reference that sample

