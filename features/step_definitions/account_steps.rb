Given /an account$/ do
  @server_proxy = ServerProxy.make!
  @account = Account.make
  @server_proxy.accounts << @account
  @account.save!
end

Then /^the account is created$/ do
  @account = Account.first
  @account.should_not == nil
end