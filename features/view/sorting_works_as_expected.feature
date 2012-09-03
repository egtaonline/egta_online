Feature: Sorting works as expected

Scenario: Viewing the index page
  Given I am signed in
  And 3 schedulers exist
  When I visit the schedulers index page
  Then I should see the following table rows:
    | real-realest |
    | fake-less    |
    | fake-more    |
  When I click on the simulator header
  Then I should see the following table rows:
    | fake-less    |
    | fake-more    |
    | real-realest |
  When I click on the simulator header
  Then I should see the following table rows:
    | real-realest |
    | fake-more    |
    | fake-less    |

