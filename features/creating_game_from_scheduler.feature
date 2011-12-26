Feature: Creating a game from scheduler
  In order to easily create games from schedulers
  As a user
  I want a button on the scheduler page to make a game.

<<<<<<< HEAD
Scenario: A scheduler exists that I want to create a game from
=======
Scenario: scheduler exists
>>>>>>> a88219d61b72ccb6ff7afbd98ad310d91711ded5
  Given I am signed in
  And there is a simulator with corresponding game scheduler
  And I am on the last game scheduler's page
  When I follow "Create game from scheduler"
  Then I should be on the last game's page
<<<<<<< HEAD
  And that game should match the game scheduler
=======
  And I should see the following table rows:
    | Name      | a=2       |
    | Size      | 2         |
    | Simulator | test-test |
    | A         | 2         |
  And that game should have the role "All" with strategies "A" and "B"
  And that game should have 3 profiles
  And there should be 3 profiles
>>>>>>> a88219d61b72ccb6ff7afbd98ad310d91711ded5
