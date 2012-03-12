class DeviationSchedulersController < GameSchedulersController
  def add_deviating_strategy
    scheduler.add_deviating_strategy(params[:role], params["#{params[:role]}_strategy"])
    respond_with(scheduler)
  end
  
  def remove_deviating_strategy
    scheduler.remove_deviating_strategy(params[:role], params[:strategy_name])
    respond_with(scheduler)
  end
end