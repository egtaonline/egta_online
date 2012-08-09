Feature: Data parser gets all the data

Scenario: Valid data
  Given a profile and simulation to match the incoming data
  When the data is parsed
  Then the symmetry group of the profile will have 240 players
  And the profile will have matching correct features observations for each of the observations




  
