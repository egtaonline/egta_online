Feature: Game schedulers schedule subgames

# Hierarchical Reduction assumes base size of 4
Scenario Outline: No prior profiles
  Given I am signed in
  And a fleshed out simulator with an empty <class> of size 2
  When I add the role <role> with size <role_size> and the strategies <strategies>
  And I add the role <role2> with size <role_size2> and the strategies <strategies2>
  Then I should see the profiles <profiles>
  
  Examples:
  | class                  | role  | role_size | strategies | role2  | role_size2 | strategies2 | profiles                                                                                                                             |
  | game_scheduler         | All   | 2         | A, B       |        |            |             | ["All: 2 A", "All: 1 A, 1 B", "All: 2 B"]                                                                                            |
  | game_scheduler         | Buyer | 1         | Bid1, Bid2 | Seller | 1          | Ask1, Ask2  | ["Buyer: 1 Bid1; Seller: 1 Ask1", "Buyer: 1 Bid2; Seller: 1 Ask1", "Buyer: 1 Bid1; Seller: 1 Ask2", "Buyer: 1 Bid2; Seller: 1 Ask2"] |
  | hierarchical_scheduler | All   | 2         | A, B       |        |            |             | ["All: 4 A", "All: 2 A, 2 B", "All: 4 B"]                                                                                            |
  | hierarchical_scheduler | Buyer | 1         | Bid1, Bid2 | Seller | 1          | Ask1, Ask2  | ["Buyer: 2 Bid1; Seller: 2 Ask1", "Buyer: 2 Bid2; Seller: 2 Ask1", "Buyer: 2 Bid1; Seller: 2 Ask2", "Buyer: 2 Bid2; Seller: 2 Ask2"] |

Scenario Outline: Schedulers find and reuse matching profiles
  Given I am signed in
  And a fleshed out simulator with an empty <class> of size 2
  And the simulator has a profile that matches the scheduler with the assignment <assignment>
  And the simulator has a profile that does not match the scheduler with assignment <assignment2>
  When I add the role <role> with size <role_size> and the strategies <strategies>
  And I add the role <role2> with size <role_size2> and the strategies <strategies2>
  Then there should be <profile_count> profiles
  
  Examples:
  | class                  | assignment                    | assignment2                   | role  | role_size | strategies | role2  | role_size2 | strategies2 | profile_count |
  | game_scheduler         | All: 2 A                      | All: 1 A, 1 B                 | All   | 2         | A, B       |        |            |             | 4             |
  | game_scheduler         | Buyer: 1 Bid1; Seller: 1 Ask1 | Buyer: 1 Bid2; Seller: 1 Ask1 | Buyer | 1         | Bid1, Bid2 | Seller | 1          | Ask1, Ask2  | 5             |
  | hierarchical_scheduler | All: 4 A                      | All: 1 A, 1 B                 | All   | 2         | A, B       |        |            |             | 4             |
  | hierarchical_scheduler | Buyer: 2 Bid1; Seller: 2 Ask1 | Buyer: 1 Bid2; Seller: 1 Ask1 | Buyer | 1         | Bid1, Bid2 | Seller | 1          | Ask1, Ask2  | 5             |