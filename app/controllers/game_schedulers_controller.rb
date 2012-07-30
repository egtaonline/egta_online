class GameSchedulersController < SchedulersController 
  def add_strategy
    scheduler.add_strategy(params[:role], params["#{params[:role]}_strategy"])
    respond_with(scheduler)
  end
  
  def remove_strategy
    scheduler.remove_strategy(params[:role], params[:strategy_name])
    respond_with(scheduler)
  end
end