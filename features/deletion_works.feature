Feature: Deletion works
  In order to maintain sanity
  As a developer
  I want to ensure that things are deleted at appropriate times

Scenario: 1 game with 1 profile, deleting the game
  Given 1 simulator
  And that simulator has the following game:
    | name | name |
  And that simulator has the following symmetric profile:
    | proto_string | "A, A" |
  And that game has that symmetric profile
  When I delete that game
  Then there should be 1 symmetric profiles

Scenario: 1 scheduler with 1 profile, deleting the scheduler
  Given 1 simulator
  And that simulator has the following symmetric game scheduler:
    | name | name |
		| size | 2    |
  And that simulator has the following symmetric profile:
    | proto_string | A, A |
  And the last scheduler has that symmetric profile
  When I delete that symmetric game scheduler
  Then there should be 1 symmetric profiles

Scenario: 1 scheduler with 1 profile, deleting a strategy
	Given 1 simulator
	And that simulator has the following symmetric game scheduler:
	  | name | name |
		| size | 2    |
	And that simulator has the following symmetric profile:
	  | proto_string | A, A |
	And the last scheduler has that symmetric profile
	And the last scheduler has the strategy "A"
	When I delete the strategy "A"
	Then there should be 1 symmetric profiles
	And the last scheduler should have 0 profiles
	
Scenario: 1 game with 1 profile, deleting a strategy
	Given 1 simulator
	And that simulator has the following game:
	  | name | name |
		| size | 2    |
	And that simulator has the following symmetric profile:
	  | proto_string | A, A |
	And that game has that symmetric profile
	And the last game has the strategy "A"
	When I delete the strategy "A" from that game
	Then there should be 1 symmetric profiles
	And the last game should have 1 profiles