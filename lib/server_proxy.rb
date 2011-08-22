require 'singleton'

class ServerProxy
  include Singleton
  
  attr_accessor :sessions, :staging_session

  def initialize
    @sessions = Net::SSH::Multi.start
    if Account.all.count > 0
      @staging_session = Net::SSH.start(Yetting.host, Account.first.username, :password => Account.first.password)
    end
    @sessions.group :scheduling do
      Account.all.each {|account| self.add_account(account)}
    end
  end

  def add_account(account)
    if @staging_session == nil
      @staging_session = Net::SSH.start(Yetting.host, account.username, :password => account.password)
    end
    @sessions.use(Yetting.host, :user => account.username, :password => account.password)
  end

  def stop
    @sessions.close
    @staging_session.close
  end

  private_class_method :new
end
