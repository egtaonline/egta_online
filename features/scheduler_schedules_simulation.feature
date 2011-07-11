Feature: Scheduler schedules simulations
  In order to simplify simulation scheduling
  As a developer
  I want all profiles to be scheduled at once

Scenario: Symmetric game scheduler schedules all of its profiles as they are added
  Given 1 simulator
  And that simulator has the following symmetric game scheduler:
    | size | 2 |
  When I add strategy "A" to that symmetric game scheduler
  Then I should have 1 simulation scheduled
  And that simulation should have profile "A: 2"
  And that simulation should have state "pending"
  When I add strategy "B" to that symmetric game scheduler
  Then I should have 3 simulations scheduled
  And all simulations should have state "pending"


# Scenario: Asymmetric game scheduler schedules all of its profiles as they are added
#   Given 1 simulator
#   And 1 run time configuration
#   And that run time configuration belongs to that simulator
#   And that simulator has the following asymmetric game scheduler:
#     | size | 2 |
#   And that asymmetric game scheduler belongs to that simulator
#   And that asymmetric game scheduler belongs to that run time configuration
#   When I add strategy "A" to that asymmetric game scheduler
#   Then I should have 1 simulation scheduled
#   And that simulation should have profile "A, A"
#   And that simulation should have state "pending"
#   When I add strategy "B" to that asymmetric game scheduler
#   Then I should have 4 simulations scheduled
#   And all simulations should have state "pending"