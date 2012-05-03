Feature: Scheduling with resque
  In order to keep scheduling orderly and open the door for priority
  As a user
  I want scheduling to occur through resque automatically

Background:
	Given one account that has passed group validation

Scenario: 1 profile interacts with queue
  Given I am signed in
  Given the following simulator:
    | parameter_hash | {:a => "2"} |
  And that simulator has the strategy array "['A', 'B']"
  When I am on the new game scheduler page
  And I fill in the following:
    | Name                   | sch  |
    | Game size              | 2    |
    | Max samples            | 10   |
    | Samples per simulation | 5    |
    | Process memory (in MB) | 1000 |
    | Time per sample        | 40   |
  And I check "Active"
  And I press "Create Game scheduler"
  Then I am on the last game scheduler's page
  When I select "All" from "role"
  And I fill in "role_count" with "2"
  And I press "Add Role"
  And I select "A" from "All_strategy"
  And I press "Add Strategy" without resque
	When I process all jobs for "profile_actions"
  Then I should have 1 profile to be scheduled
  When I am on the new game scheduler page
  And I fill in the following:
    | Name                   | sch2  |
    | Game size              | 2    |
    | Max samples            | 10   |
    | Samples per simulation | 5    |
    | Process memory (in MB) | 1000 |
    | Time per sample        | 40   |
  And I check "Active"
  And I press "Create Game scheduler"
  Then I am on the last game scheduler's page
  And I select "All" from "role"
  And I fill in "role_count" with "2"
  And I press "Add Role"
  And I select "A" from "All_strategy"
  And I press "Add Strategy" without resque
	When I process all jobs for "profile_actions"
  Then I should have 1 profile to be scheduled

