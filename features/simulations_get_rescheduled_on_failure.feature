Feature: Simulations get rescheduled on failure
  In order to limit periodic jobs
  As an administrator
  I want simulations to be rescheduled when they fail

Scenario: Simulation fails with an active symmetric game scheduler
  Given 1 simulator
  And that simulator has the following symmetric game scheduler:
    | parameter_hash | {a: 2} |
    | active         | true   |
  And I add strategy "A" to that symmetric game scheduler
  When I fail a simulation
  Then that simulation should have state "failed"
  And a new simulation should exist with identical settings to that simulation

Scenario: Simulation fails with an inactive symmetric game scheduler
  Given 1 simulator
  And that simulator has the following symmetric game scheduler:
    | parameter_hash | {a: 2} |
    | active         | false  |
  And I add strategy "A" to that symmetric game scheduler
  When I fail a simulation
  Then that simulation should have state "failed"
  And a new simulation should not be created



