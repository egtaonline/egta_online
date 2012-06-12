Feature: Editing schedulers causes new profiles to be created

Scenario: A scheduler with existing profiles has its configuration edited
  Given I am signed in
  And a fleshed out simulator with a non-empty game scheduler exists
  When I edit a parameter of that scheduler
  Then new profiles should be created




  
