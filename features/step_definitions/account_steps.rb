Given /an Account$/ do
  @account = Account.make
end

Then /^the account is created$/ do
  @account = Account.first
  @account.should_not == nil
end