module StrategyController
  def add_role
    resource.add_role(role)
    redirect_to resource_url
  end

  def remove_role
    resource.remove_role(role)
    redirect_to resource_url
  end

  def add_strategy
    resource.add_strategy(role, params["#{role}_strategy"])
    redirect_to resource_url
  end

  def remove_strategy
    resource.remove_strategy(role, params[:strategy_name])
    redirect_to resource_url
  end

  private

  def role
    @role ||= params[:role]
  end
end