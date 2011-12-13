class GameSchedulersController < SchedulersController
  include StrategyController
  
  def add_role
    resource.add_role(role, params[:role_count])
    redirect_to resource_url
  end
end