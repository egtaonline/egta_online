class AccountsController < AdminController

  def index
    @accounts = Account.all
  end

  def show
    @account = Account.find(params[:id])
  end

  def new
    @account = Account.new
  end

  def edit
    @account = Account.find(params[:id])
  end

  def create
    @account = Account.new(params[:account])
    if @account.save
      flash[:notice] = 'Account was successfully created.'
      redirect_to @account
    else
      render :action => "new"
    end
  end

  def update
    @account = Account.find(params[:id])
    if @account.update_attributes(params[:account])
      flash[:notice] = 'Account was successfully updated.'
      redirect_to @account
    else
      render :action => "edit"
    end
  end

  def destroy
    @account = Account.find(params[:id])
    @account.destroy

    redirect_to accounts_url
  end
end
