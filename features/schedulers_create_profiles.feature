Feature: Schedulers create profiles
  In order to keep profiles modular
  As a db-admin
  I want schedulers to be responsible for creating profiles

Scenario: Profile already exists with the same configuration
  Given I am signed in
  Given the following simulator:
    | parameter_hash | {a: 2} |
  And that simulator has the following role:
    | name | All |
  And that simulator has the following profile:
    | proto_string   | All: A, A |
    | parameter_hash | {a: 2}    |
  And that profile has 1 sample record
  Then there should be 1 profiles
  And that simulator has the following game scheduler:
    | parameter_hash | {a: 2} |
  And I am on the last game scheduler's page
  When I select "All" from "role"
  And I fill in "role_count" with "2"
  And I press "Add Role"
  When I select "A" from "All_strategy"
  And I press "Add Strategy"
  When I select "B" from "All_strategy"
  And I press "Add Strategy"
  Then there should be 3 profiles
  
Scenario: Asymmetric profile generation
  Given I am signed in
  Given the following simulator:
    | parameter_hash | {a: 2} |
  And I am on the last simulator's page
  When I fill in "role" with "Player1"
  And I press "Add Role"
  And I fill in "Player1_strategy" with "A"
  And I press "Add Strategy"
  And I fill in "Player1_strategy" with "B"
  And I press "Add Strategy"
  When I fill in "role" with "Player2"
  And I press "Add Role"
  Then I should see "Player2"
  And I fill in "Player2_strategy" with "A"
  And I press "Player2"
  And I fill in "Player2_strategy" with "B"
  And I press "Player2"
  Then I should see "B"
  And that simulator has the following game scheduler:
    | parameter_hash | {a: 2} |
  And I am on the last game scheduler's page
  When I select "Player1" from "role"
  And I fill in "role_count" with "1"
  And I press "Add Role"
  When I select "Player2" from "role"
  And I fill in "role_count" with "1"
  And I press "Add Role"
  When I select "A" from "Player1_strategy"
  And I press "Add Strategy"
  When I select "B" from "Player1_strategy"
  And I press "Add Strategy"
  When I select "A" from "Player2_strategy"
  And I press "Player2"
  When I select "B" from "Player2_strategy"
  And I press "Player2"
  Then there should be 4 profiles
  
@wip
Scenario: Hierarchical scheduler
  Given I am signed in
  Given the following simulator:
    | parameter_hash | {a: 2} |
  And I am on the last simulator's page
  When I fill in "role" with "Player1"
  And I press "Add Role"
  And I fill in "Player1_strategy" with "A"
  And I press "Add Strategy"
  And I fill in "Player1_strategy" with "B"
  And I press "Add Strategy"
  When I fill in "role" with "Player2"
  And I press "Add Role"
  And I fill in "Player2_strategy" with "A"
  And I press "Player2"
  And I fill in "Player2_strategy" with "B"
  And I press "Player2"
  And that simulator has the following hierarchical scheduler:
    | parameter_hash    | {a: 2} |
    | game_size         | 8      |
    | agents_per_player | 4      |
  And I am on the last hierarchical scheduler's page
  When I select "Player1" from "role"
  And I fill in "role_count" with "1"
  And I press "Add Role"
  When I select "Player2" from "role"
  And I fill in "role_count" with "1"
  And I press "Add Role"
  When I select "A" from "Player1_strategy"
  And I press "Add Strategy"
  When I select "B" from "Player1_strategy"
  And I press "Add Strategy"
  When I select "A" from "Player2_strategy"
  And I press "Player2"
  When I select "B" from "Player2_strategy"
  And I press "Player2"
  Then there should be 4 profiles
  And I should see "Player1: A, A, A, A; Player2: A, A, A, A"
  And I should see "Player1: A, A, A, A; Player2: B, B, B, B"
  And I should see "Player1: B, B, B, B; Player2: A, A, A, A"
  And I should see "Player1: B, B, B, B; Player2: B, B, B, B"