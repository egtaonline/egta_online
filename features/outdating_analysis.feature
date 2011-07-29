Feature: Outdating analysis
  In order to keep track of current analysis
  As a user
  I want new samples to outdate analysis items

Scenario: Adding a sample, no games
  Given 1 simulator
  And that simulator has the following symmetric profile:
    | proto_string   | A, A   |
    | parameter_hash | {a: 2} |
  And 1 analysis item
  And that analysis item belongs to that symmetric profile
  When the profile_entry of that symmetric profile has a sample
  Then that analysis item is outdated

Scenario: Adding a sample, multiple games
  Given 1 simulator
  And that simulator has the following symmetric profile:
    | proto_string   | A, A   |
    | parameter_hash | {a: 2} |
  And 2 games
  And those games have that symmetric profile and an analysis item
  When the profile_entry of that symmetric profile has a sample
  Then the games' analysis items are outdated





