Feature: Users can sign in successfully only with a correct credential

Scenario Outline: User with existing login tries to sign in
    Given I have a login
    And I am on the sign in page
    And I sign in with <credentials>
    And I press "Sign in"
    Then I should be on the <page> page
    And I should see <message>

    Examples:
    | credentials            | page    | message                      |
    | valid credentials      | home    | "Signed in successfully."    |
    | the incorrect password | sign in | "Invalid email or password." |
    | an invalid email       | sign in | "Invalid email or password." |