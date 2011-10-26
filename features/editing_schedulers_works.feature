Feature: Editing schedulers works
  In order to minimize scheduler creation
  As the db admin
  I want editing schedulers to work as expected

Scenario: Editing a scheduler leads to profiles being dropped and new profiles being created
Given I am signed in
Given the following simulator:
  | parameter_hash | {:a=>"2"} |
And that simulator has the following role:
  | name | All |
And that simulator has the following game scheduler:
  | parameter_hash | {:a=>"2"} |
And I am on the last game scheduler's page
When I select "All" from "role"
And I fill in "role_count" with "2"
And I press "Add Role"
When I select "A" from "All_strategy"
And I press "Add Strategy"
When I select "B" from "All_strategy"
And I press "Add Strategy"
Then there should be 3 profiles
When I follow "Edit GameScheduler"
And I fill in "3" for "A"
And I press "Update Game scheduler"
Then I should see the following table rows:
  | A | 3 |
And there should be 6 profiles