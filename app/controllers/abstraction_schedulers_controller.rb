class AbstractionSchedulersController < SchedulersController
  def add_role
    if params[:role_count].to_i >= params[:reduced_count].to_i
      scheduler.add_role(params[:role], params[:role_count].to_i, params[:reduced_count].to_i)
      respond_with(scheduler)
    else
      flash[:notice] = "Reduced count cannot be larger than full count."
      redirect_to(scheduler)
    end
  end

  def add_strategy
    scheduler.add_strategy(params[:role], params["#{params[:role]}_strategy"])
    respond_with(scheduler)
  end

  def remove_strategy
    scheduler.remove_strategy(params[:role], params[:strategy_name])
    respond_with(scheduler)
  end
end