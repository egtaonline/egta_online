class AccountAdder
  @queue = :nyx_actions

  def self.perform(account_id)
    @sp ||= ServerProxy.instance
    account = Account.find(account_id) rescue nil
    @sp.add_account(account) if account != nil
  end
end