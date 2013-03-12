class Api::V3::BaseController < ActionController::Base
  respond_to :json
  before_filter :authenticate_user!

  private

  def validate_param(param_symbol)
    if params[param_symbol] == nil || params[param_symbol] == ""
      respond_with({error: "you did not specify a #{param_symbol}"}, status: 422, location: nil)
    end
  end
end