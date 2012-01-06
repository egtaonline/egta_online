Feature: Editing schedulers works
  In order to minimize scheduler creation
  As the db admin
  I want editing schedulers to work as expected

Scenario: Editing a scheduler leads to profiles being dropped and new profiles being created
  Given I am signed in
  Given 1 simulator
  And that simulator has 1 role
  And that role has 2 strategies
  And that simulator has 1 game scheduler
  And I am on the last game scheduler's page
  And I fill in "role_count" with "2"
  And I press "Add Role"
  And I press "Add Strategy"
  And I press "Add Strategy"
  Then there should be 3 profiles
  When I follow "Edit GameScheduler"
  And I fill in "3" for "A"
  And I press "Update Game scheduler"
  Then I should see the following table rows:
    | A | 3 |
  And there should be 6 profiles