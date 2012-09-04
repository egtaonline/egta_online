Feature: Sorting works as expected

Scenario Outline: Viewing the index page
  Given I am signed in
  And 3 <objects> exist
  When I visit the <objects> index page
  Then I should see the <objects> in the default order
  When I click on the <column> header
  Then I should see the <objects> sorted by <column> in ascending order
  When I click on the <column> header
  Then I should see the <objects> sorted by <column> in descending order

  Examples:
  | objects     | column      |
  | schedulers  | simulator   |
  | games       | size        |
  | simulations | state       |
  | simulators  | description |

Scenario: Viewing a scheduler page
  Given I am signed in
  And a generic_scheduler exists
  And that generic_scheduler has 3 profiles
  When I visit that generic_scheduler's page
  Then I should see the profiles in the default order
  When I click on the sample_count header
  Then I should see the profiles sorted by sample_count in ascending order
  When I click on the sample_count header
  Then I should see the profiles sorted by sample_count in descending order