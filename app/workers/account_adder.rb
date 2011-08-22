class AccountAdder
  @queue = :nyx_actions

  def self.perform(account_id)
    account = Account.find(account_id) rescue nil
    NYX_PROXY.add_account(account) if account != nil
  end
end