class AccountsController < EntitiesController
  def create
    Net::SSH.start(Yetting.host, params[single_name][:username], :password => params[single_name][:password]) do |s|
      s.exec!("echo #{KEY} >> ~/.ssh/authorized_keys")
    end
    @entry = klass.new(username: params[single_name][:username], active: params[single_name][:active])
    if @entry.save
      flash[:notice] = "#{klass_name} was successfully created."
      redirect_to url_for(:action => "show", :id => @entry.id)
    else
      flash[:alert] = "#{klass_name} failed to save."
      render "new"
    end
  end
end