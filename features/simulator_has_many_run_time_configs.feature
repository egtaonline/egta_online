Feature: Simulator has many run time configurations
  In order to manage virtual games
  As a searcher
  I want to be able to get run time configurations from simulators

Scenario: 1 simulator, 1 profile
  Given 1 simulator
  And that simulator has the following profile:
    | proto_string | A, A |
  When I query that simulator for run time configurations
  Then I receive "[{a: 2}]"

Scenario: 1 simulator, 2 profiles, same configuration
  Given 1 simulator
  And that simulator has the following profiles:
    | proto_string |
    | A, A         |
    | B, B         |
  When I query that simulator for run time configurations
  Then I receive "[{a: 2}]"

Scenario: 1 simulator, 2 profiles, different configurations
  Given 1 simulator
  And that simulator has the following profiles:
    | proto_string |
    | A, A         |
    | B, B         |
  And that simulator has the following run time configuration:
    | parameters | {a: 1, b: 2} |
  And the second profile belongs to that run time configuration
  When I query that simulator for run time configurations
  Then I receive "[{a: 2}, {a: 1, b: 2}]"