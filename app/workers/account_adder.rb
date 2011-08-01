class AccountAdder
  @queue = :admin

  def self.perform(account_id)
    account = Account.find(account_id)
    Resque::NYX_PROXY.add_account(account)
  end
end