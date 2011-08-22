module ServerProxy
  def add_account(account)
    if @@staging_session == nil
      @@staging_session = Net::SSH.start(Yetting.host, account.username, :password => account.password)
    end
    @@sessions.use(Yetting.host, :user => account.username, :password => account.password)
  end
  
  @@sessions = Net::SSH::Multi.start
  if Account.all.count > 0
    @@staging_session = Net::SSH.start(Yetting.host, Account.first.username, :password => Account.first.password)
  end
  @@sessions.group :scheduling do
    if @@staging_session == nil
      @@staging_session = Net::SSH.start(Yetting.host, account.username, :password => account.password)
    end
    @@sessions.use(Yetting.host, :user => account.username, :password => account.password)
  end
end
