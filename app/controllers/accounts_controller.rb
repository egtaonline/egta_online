class AccountsController < EntitiesController
  def create
    begin
      Net::SSH.start(Yetting.host, params[:account][:username], password: params[:account][:password]) do |s|
        s.exec!("echo #{KEY} >> ~/.ssh/authorized_keys")
      end
      create!
    rescue
      new!(alert: "Invalid username/password or connection difficulty.")
    end
  end
end