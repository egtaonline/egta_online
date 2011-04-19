Feature: Server proxy maintains ssh connections
  In order to get CAC off my back
  As an admin
  I want the server proxy to maintain ssh connections

Scenario: one account with a password, server proxy is created
  Given an account
  And an existing server proxy
  When the server proxy is activated
  Then a ssh session is created for the account