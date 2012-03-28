Feature: Schedulers create profiles
  In order to keep profiles modular
  As a db-admin
  I want schedulers to be responsible for creating profiles

Scenario: Profile already exists with the same configuration
  Given I am signed in
  Given the following simulator:
    | parameter_hash | {a: 2} |
  And that simulator has 1 role
  And that role has the strategies "A" and "B"
  And that simulator has the following profile:
    | name   | All: 2 A |
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

Scenario: Hierarchical scheduler
  Given I am signed in
  Given the following simulator:
    | parameter_hash | {a: 2} |
  And I am on the last simulator's page
  When I fill in "role" with "Buyer"
  And I press "Add Role"
  And I fill in "Buyer_strategy" with "A"
  And I press "Add Strategy"
  And I fill in "Buyer_strategy" with "B"
  And I press "Add Strategy"
  When I fill in "role" with "Seller"
  And I press "Add Role"
  And I fill in "Seller_strategy" with "A"
  And I press "Seller"
  And I fill in "Seller_strategy" with "B"
  And I press "Seller"
  And that simulator has the following hierarchical scheduler:
    | parameter_hash    | {a: 2} |
    | size              | 40     |
    | agents_per_player | 10     |
  And I am on the last hierarchical scheduler's page
  When I select "Buyer" from "role"
  And I fill in "role_count" with "2"
  And I press "Add Role"
  When I select "Seller" from "role"
  And I fill in "role_count" with "2"
  And I press "Add Role"
  When I select "A" from "Buyer_strategy"
  And I press "Add Strategy"
  When I select "B" from "Buyer_strategy"
  And I press "Add Strategy"
  When I select "A" from "Seller_strategy"
  And I press "Seller"
  When I select "B" from "Seller_strategy"
  And I press "Seller"
  Then there should be 9 profiles
  And I should see "Buyer: 20 A; Seller: 20 A"
  And I should see "Buyer: 10 A, 10 B; Seller: 20 A"
  And I should see "Buyer: 20 B; Seller: 20 A"
  And I should see "Buyer: 20 A; Seller: 10 A, 10 B"
  And I should see "Buyer: 10 A, 10 B; Seller: 10 A, 10 B"
  And I should see "Buyer: 20 B; Seller: 10 A, 10 B"
  And I should see "Buyer: 20 A; Seller: 20 B"
  And I should see "Buyer: 10 A, 10 B; Seller: 20 B"
  And I should see "Buyer: 20 B; Seller: 20 B"