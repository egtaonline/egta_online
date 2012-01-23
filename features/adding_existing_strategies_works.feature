Feature: Adding existing strategies works

Scenario: The strategy I want to add already exists
  Given I am signed in
  Given 1 simulator
  And the strategy "BayesianPricing:noRA:0.0"
  And I am on the last simulator's page
  When I fill in "role" with "All"
  And I press "Add Role"
  Then I am on the last simulator's page
	When I fill in "All_strategy" with "BayesianPricing:noRA:0.0"
	And I press "Add Strategy"
	Then I am on the last simulator's page
  And I should see "BayesianPricing:noRA:0.0"
  
