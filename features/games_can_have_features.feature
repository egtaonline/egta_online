Feature: Games can have features

Scenario: Game with no features, adding a feature
  Given I am signed in
  Given 1 game
  And I am on the last game's page
  When I fill in "name" with "feature1"
  And I fill in "expected_value" with "0.95"
  And I press "Add Feature"
  Then I should see "feature1"
  And I should see "0.95"
  When I follow "Remove"
  Then I should not see "feature1"
  And I should not see "0.95"