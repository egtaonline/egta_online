class ApplicationController < ActionController::Base
  stream

  before_filter :authenticate_user!
  protect_from_forgery

end
