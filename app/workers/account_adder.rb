class AccountAdder
  @queue = :nyx_actions
  include ServerProxy

  def self.perform(account_id)
    account = Account.find(account_id) rescue nil
    add_account(account) if account != nil
  end
end