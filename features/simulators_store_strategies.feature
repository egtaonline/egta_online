Feature: Simulators store strategies
  In order to simplify adding strategies to schedulers
  As a user
  I want simulators to store strategies

Background:
  Given I am signed in

@wip
Scenario: Simulator has no strategies
  Given a simulator exists
  And I am on the last simulator's page
  When I fill in "role" with "Player1"
  And I press "Add Role"
  Then I am on the last simulator's page
  And I should see "Player1"
	When I fill in "Player1_strategy" with "A:Strategy"
	And I press "Add Strategy"
	Then I am on the last simulator's page
  And I should see "Player1"
	And I should see "A:Strategy"
	And that simulator should have a role named "Player1" with the strategy array "['A:Strategy']"
	When I fill in "Player1_strategy" with "B:MONEY"
	And I press "Add Strategy"
	Then that simulator should have a role named "Player1" with the strategy array "['A:Strategy', 'B:MONEY']"



