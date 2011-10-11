class GameSchedulersController < SchedulersController
  include StrategyController
  defaults :resource_class => GameScheduler, :collection_name => 'schedulers', :instance_name => 'scheduler'
  
  def add_role
    resource.add_role(role, params[:role_count])
    redirect_to resource_url
  end
end