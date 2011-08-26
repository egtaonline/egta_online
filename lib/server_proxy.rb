require 'singleton'

class ServerProxy
  include Singleton
  
  attr_accessor :sessions, :sftp, :staging_session

  def initialize
    @sessions = Net::SSH::Multi.start
    if Account.all.count > 0
      @sftp = Net::SFTP.start(Yetting.host, Account.first.username)
      @staging_session = Net::SSH.start(Yetting.host, Account.first.username)
    end
    @sessions.group :scheduling do
      Account.all.each {|account| self.add_account(account)}
    end
  end

  def add_account(account)
    if @sftp == nil
      @sftp = Net::SFTP.start(Yetting.host, account.username)
      @staging_session = Net::SSH.start(Yetting.host, Account.first.username)
    end
    @sessions.use(Yetting.host, :user => account.username)
    @sessions.group account.username do
      @sessions.use(Yetting.host, :user => account.username)
    end
  end

  def stop
    @sessions.close
    @sftp.close
  end
end
