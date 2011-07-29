class ApplicationController < ActionController::Base

  before_filter :authenticate_user!
  protect_from_forgery

  def prep_work
  end

end
