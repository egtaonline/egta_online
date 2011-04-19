#Controller for cluster login accounts
class AccountsController < AnalysisController
  before_filter :find_account, :only => [:show, :edit, :update, :destroy]

  def index
    @accounts = Account.all
  end

  def show
  end

  def new
    @account = Account.new
  end

  def edit
  end

  def create
    @account = Account.new(params[:account])
    @server_proxy = ServerProxy.find(params[:serv][:server_proxy_id])
    @server_proxy.accounts << @account
    if @account.save
      flash[:notice] = 'Account was successfully created.'
      redirect_to @account
    else
      render :action => "new"
    end
  end

  def update
    if @account.update_attributes(params[:account])
      flash[:notice] = 'Account was successfully updated.'
      redirect_to @account
    else
      render :action => "edit"
    end
  end

  def destroy
    @account.destroy

    redirect_to accounts_url
  end

  protected

  def find_account
    @account = Account.find(params[:id])
  end
end
