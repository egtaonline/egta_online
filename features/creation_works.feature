Feature: Creation works correctly
  In order to maintain sanity
  As a user
  I want creation to work without killing itself

Background:
  Given a user
  And I am logged in as that user

Scenario: Simulator creation works
  Given an account
  And I am on the new simulator page
  When I fill in "Name" with "epp_sim"
  And I fill in "Version" with "test"
  And I attach the file "/Users/bcassell/Ruby/egt_working_directory/epp_sim.zip" to "Zipped simulator"
  And I press "Create Simulator"
  Then the simulator is created
  And I am on the show page for the simulator

Scenario: Game creation works
  Given a simulator
  And I am on the new game page
  When I fill in "Name" with "test"
  And I press "Create Game"
  Then the game is created
  And I am on the show page for the game