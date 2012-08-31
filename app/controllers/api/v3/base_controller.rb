class Api::V3::BaseController < ActionController::Base
  respond_to :json
  before_filter :authenticate_user!
end