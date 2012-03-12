class GameSchedulersController < SchedulersController 
  def add_role
    scheduler.add_role(params[:role], params[:role_count])
    respond_with(scheduler)
  end
  
  def add_strategy
    scheduler.add_strategy(params[:role], params["#{params[:role]}_strategy"])
    respond_with(scheduler)
  end
  
  def remove_role
    scheduler.remove_role(params[:role])
    respond_with(scheduler)
  end
  
  def remove_strategy
    scheduler.remove_strategy(params[:role], params[:strategy_name])
    respond_with(scheduler)
  end
end