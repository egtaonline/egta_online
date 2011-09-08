Feature: Scheduling with resque
  In order to keep scheduling orderly and open the door for priority
  As a user
  I want scheduling to occur through resque automatically

Background:
	Given 1 account
	
Scenario: 1 profile interacts with queue
  Given I am signed in
  And 1 simulator
  And that simulator has the strategy array "['A', 'B']"
  When I am on the new symmetric game scheduler page
  And I fill in the following:
    | Name                   | sch  |
    | Game size              | 2    |
    | Max samples            | 10   |
    | Samples per simulation | 5    |
    | Process memory (in MB) | 1000 |
    | Time per sample        | 40   |
  And I check "Active"
  And I press "Create Symmetric game scheduler"
  And I select "A" from "strategy"
  And I press "Add" without resque
	When I process all jobs for "profile_actions"
  Then I should have 1 simulation scheduled
  When I am on the new symmetric game scheduler page
  And I fill in the following:
    | Name                   | sch2  |
    | Game size              | 2    |
    | Max samples            | 10   |
    | Samples per simulation | 5    |
    | Process memory (in MB) | 1000 |
    | Time per sample        | 40   |
  And I check "Active"
  And I press "Create Symmetric game scheduler"
  And I select "A" from "strategy"
  And I press "Add" without resque
	When I process the next job for "profile_actions"
  Then I should have 1 simulation scheduled

Scenario: a failed simulation gets rescheduled
  Given I am signed in
  And 1 simulator
  And that simulator has the strategy array "['A', 'B']"
  When I am on the new symmetric game scheduler page
  And I fill in the following:
    | Name                   | sch  |
    | Game size              | 2    |
    | Max samples            | 10   |
    | Samples per simulation | 5    |
    | Process memory (in MB) | 1000 |
    | Time per sample        | 40   |
  And I check "Active"
  And I press "Create Symmetric game scheduler"
  And I select "A" from "strategy"
  And I press "Add" without resque
	When I process all jobs for "profile_actions"
  Then I should have 1 simulation scheduled
  When I fail a simulation
  Then I should have 2 simulations
  And I should have 1 simulation scheduled
  And a new simulation should exist with identical settings to that simulation

