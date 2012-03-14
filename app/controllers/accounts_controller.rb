class AccountsController < ApplicationController
  respond_to :html
  
  expose(:accounts){Account.order_by(params[:sort], params[:direction]).page(params[:page])}
  expose(:account)
  
  def create
    account.save
    respond_with(account)
  end
  
  def update
    account.save
    respond_with(account)
  end
end