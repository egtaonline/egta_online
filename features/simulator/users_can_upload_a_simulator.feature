Feature: Users can upload a simulator

@wip
Scenario: User uploads a new simulator
  Given I am signed in
  When I upload a new simulator
  Then I should see the simulator's name and default configuration
  And the simulator should be eventually be set up on the server
