class AccountsController < ApplicationController
  respond_to :html
  
  expose(:accounts){Account.page(params[:page])}
  expose(:account)
  
  def create
    account.save
    respond_with(account)
  end
  
  def update
    account.save
    respond_with(account)
  end
  
  def destroy
    account.destroy
    respond_with(account)
  end
end