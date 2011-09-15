Feature: Scheduler creation with ajax
  In order to keep scheduler creation to a single page
  As a developer
  I want to ajaxify it

Background:
  Given I am signed in

@javascript
Scenario: AJAX parameter switching works
  Given the following simulators:
    | name  | version | parameter_hash |
    | testA | alpha   | {a: 2, b: 1}   |
    | testB | beta    | {a: 3, c: 4}   |
  When I am on the new game scheduler page
  Then the "A" field should contain "2"
  And the "B" field should contain "1"
  When I select "testB" from "Simulator"
  And the "C" field should contain "4"
  Then the "A" field should contain "3"

@javascript
Scenario: Editing parameters results in a scheduler with the appropriate parameter hash
  Given the following simulators:
    | name  | version | parameter_hash |
    | testA | alpha   | {a: 2, b: 1}   |
    | testB | beta    | {a: 3, c: 4}   |
  When I am on the new game scheduler page
  And I select "testB" from "Simulator"
  And I fill in the following:
    | Name                   | sch  |
    | Game size              | 2    |
    | Max samples            | 10   |
    | Samples per simulation | 5    |
    | Process memory (in MB) | 1000 |
    | Time per sample        | 40   |
    | C                      | 5    |
  And I press "Create Game scheduler"
  And show me the page
  Then I should be on the last game scheduler's page
  And I should see the following table rows:
    | Name                   | sch  |
    | Game size              | 2    |
    | Max samples            | 10   |
    | Samples per simulation | 5    |
    | Process memory (in MB) | 1000 |
    | Time per sample        | 40   |
    | A                      | 3    |
    | C                      | 5    |









