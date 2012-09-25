class DeviationSchedulersController < GameSchedulersController
  def add_deviating_strategy
    scheduler.add_deviating_strategy(params[:role], params[:strategy])
    respond_with(scheduler)
  end

  def remove_deviating_strategy
    scheduler.remove_deviating_strategy(params[:role], params[:strategy])
    respond_with(scheduler)
  end
end