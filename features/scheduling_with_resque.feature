# Feature: Scheduling with resque
#   In order to keep scheduling orderly and open the door for priority
#   As a user
#   I want scheduling to occur through resque automatically
# 
# @wip
# Scenario: 1 profile interacts with queue
#   Given I am signed in
#   And 1 simulator
#   And that simulator has the strategy array "['A', 'B']"
#   When I am on the new symmetric game scheduler page
#   And I fill in the following:
#     | Name                   | sch  |
#     | Game size              | 2    |
#     | Max samples            | 10   |
#     | Samples per simulation | 5    |
#     | Process memory (in MB) | 1000 |
#     | Time per sample        | 40   |
#   And I check "Active"
#   And I press "Create Symmetric game scheduler"
#   And I select "A" from "strategy"
#   And I press "Add"
#   Then I should have 1 simulation scheduled
#   When I am on the new symmetric game scheduler page
#   And I fill in the following:
#     | Name                   | sch2  |
#     | Game size              | 2    |
#     | Max samples            | 10   |
#     | Samples per simulation | 5    |
#     | Process memory (in MB) | 1000 |
#     | Time per sample        | 40   |
#   And I check "Active"
#   And I press "Create Symmetric game scheduler"
#   And I select "A" from "strategy"
#   And I press "Add"
#   Then I should have 1 simulation scheduled
# 
# @wip
# Scenario: a failed simulation gets rescheduled
#   Given I am signed in
#   And 1 simulator
#   And that simulator has the strategy array "['A', 'B']"
#   When I am on the new symmetric game scheduler page
#   And I fill in the following:
#     | Name                   | sch  |
#     | Game size              | 2    |
#     | Max samples            | 10   |
#     | Samples per simulation | 5    |
#     | Process memory (in MB) | 1000 |
#     | Time per sample        | 40   |
#   And I check "Active"
#   And I press "Create Symmetric game scheduler"
#   And I select "A" from "strategy"
#   And I press "Add"
#   Then I should have 1 simulation scheduled
#   When I fail a simulation
#   Then I should have 2 simulations
#   And I should have 1 simulation scheduled
#   And a new simulation should exist with identical settings to that simulation
# 
# Scenario: a scheduled simulation gets queued
#   Given a fake server proxy
#   Given I am signed in
#   And 1 simulator
#   And that simulator has the strategy array "['A', 'B']"
#   When I am on the new symmetric game scheduler page
#   And I fill in the following:
#     | Name                   | sch  |
#     | Game size              | 2    |
#     | Max samples            | 10   |
#     | Samples per simulation | 5    |
#     | Process memory (in MB) | 1000 |
#     | Time per sample        | 40   |
#   And I check "Active"
#   And I press "Create Symmetric game scheduler"
#   And I select "A" from "strategy"
#   And I press "Add" without resque
#   Then "SymmetricProfileAssociater" should have "1" job queued
#   When I process the next job for "profile_actions"
#   Then "ProfileScheduler" should have "1" job queued
#   Then I should have a "ProfileScheduler" job queued with "[Scheduler.last.id, Profile.last.id]"
#   When I process the next job for "scheduling"
#   Then "SimulationQueuer" should have "1" job queued
#   Then I should have a "SimulationQueuer" job queued with "[Simulation.last.id]"
#   When I process the next job for "nyx_actions"
#   Then I should have a "YAMLCreator" job queued with "[Simulation.last.id]"
#   And I should have a "FolderCreator" job queued with "[Simulation.last.id]"
#   And I should have a "PBSScripter" job queued with "[Simulation.last.id]"
#   When I process the next job for "nyx_actions"
#   Then the file "tmp/temp.yaml" should exist
#   When I process the next job for "nyx_actions"
#   And I process the next job for "nyx_actions"

