Feature: Data parser gets all the data

@wip
Scenario: Valid data
  Given a profile and simulation to match the incoming data
  When the data is parsed
  Then the simulation will have the status complete
  And the profile will have valid observations




  
