Feature: Simulator has many run time configurations
  In order to manage virtual games
  As a searcher
  I want to be able to get run time configurations from simulators

Scenario: 1 simulator, 1 profile
  Given 1 simulator
  And 1 profile
  And that profile belongs to that simulator
  And the following run time configuration:
    | parameters | {a: 1, b: -1} |
  And that profile belongs to that run time configuration
  When I query that simulator for run time configurations
  Then I receive "[{a: 1, b: -1}]"

Scenario: 1 simulator, 2 profiles, same configuration
  Given 1 simulator
  And 1 profile
  And that profile belongs to that simulator
  And the following run time configuration:
    | parameters | {a: 1, b: -1} |
  And that profile belongs to that run time configuration
  And 1 profile
  And that profile belongs to that simulator
  And that profile belongs to that run time configuration
  When I query that simulator for run time configurations
  Then I receive "[{a: 1, b: -1}]"

Scenario: 1 simulator, 2 profiles, different configurations
  Given 1 simulator
  And 1 profile
  And that profile belongs to that simulator
  And the following run time configuration:
    | parameters | {a: 1, b: -1} |
  And that profile belongs to that run time configuration
  And 1 profile
  And that profile belongs to that simulator
  And the following run time configuration:
    | parameters | {a: 1, b: 2} |
  And that profile belongs to that run time configuration
  When I query that simulator for run time configurations
  Then I receive "[{a: 1, b: -1}, {a: 1, b: 2}]"