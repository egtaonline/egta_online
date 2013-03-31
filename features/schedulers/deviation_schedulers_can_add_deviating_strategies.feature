Feature: Deviation schedulers can add and remove deviating strategies

Scenario Outline: No prior profiles
  Given I am signed in
  And a fleshed out simulator with an empty <class> of size 2 exists
  When I add the role All with the strategy A to the scheduler
  And I add the deviating strategy B to the role All on the scheduler
  Then I should see these profiles: <profiles>

  Examples:
  | class                            | profiles                      |
  | deviation_scheduler              | ["All: 2 A", "All: 1 A, 1 B"] |
  | hierarchical_deviation_scheduler | ["All: 2 A", "All: 1 A, 1 B"] |
  | dpr_deviation_scheduler          | ["All: 2 A", "All: 1 A, 1 B"] |

Scenario Outline: Schedulers find and reuse matching profiles
  Given I am signed in
  And a fleshed out simulator with an empty <class> of size 2 exists
  And the scheduler's simulator instance has a profile with the assignment <assignment>
  And a different simulator instance has a profile with the assignment <assignment2>
  When I add the role All with the strategy A to the scheduler
  And I add the deviating strategy B to the role All on the scheduler
  Then there should be 3 profiles

  Examples:
  | class                            | assignment    | assignment2 |
  | deviation_scheduler              | All: 1 A, 1 B | All: 2 A    |
  | hierarchical_deviation_scheduler | All: 1 A, 1 B | All: 2 A    |
  | dpr_deviation_scheduler          | All: 1 A, 1 B | All: 2 A    |

Scenario Outline: Removing a strategy or role should trim the set of profiles to be scheduled without destroying the profiles
  Given I am signed in
  And a fleshed out simulator with an empty <class> of size 2 exists
  And the scheduler's simulator instance has a profile with the assignment <assignment>
  And a different simulator instance has a profile with the assignment <assignment2>
  And I add the role All with the strategy A to the scheduler
  And I add the deviating strategy B to the role All on the scheduler
  When I remove the deviation strategy B on role All from the scheduler
  Then the scheduler should have 1 profiles
  And there should be 3 profiles
  When I remove the role All from the scheduler
  Then the scheduler should have 0 profiles
  And there should be 3 profiles

  Examples:
  | class                            | assignment  | assignment2   |
  | deviation_scheduler              | All: 2 A    | All: 1 A, 1 B |
  | hierarchical_deviation_scheduler | All: 2 A    | All: 1 A, 1 B |
  | dpr_deviation_scheduler          | All: 2 A    | All: 1 A, 1 B |