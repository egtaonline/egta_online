class AccountAdder
  @queue = :admin

  def self.perform(account_id)
    account = Account.find(account_id) rescue nil
    Resque::NYX_PROXY.add_account(account) if account != nil
  end
end