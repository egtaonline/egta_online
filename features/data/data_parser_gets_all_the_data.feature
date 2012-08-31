Feature: Data parser gets all the data

Scenario: Valid data
  Given a profile and simulation to match the incoming data
  When the data is parsed
  Then the simulation will be in the complete state
  And the profile will have valid observations




  
