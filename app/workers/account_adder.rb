class AccountAdder
  @queue = :nyx_actions

  def self.perform(account_id)
    @sp ||= ServerProxy.instance
    account = Account.find(account_id) rescue nil
    if account != nil
      @sp.add_account(account)
      puts "adding account #{account.username}"
    end
  end
end