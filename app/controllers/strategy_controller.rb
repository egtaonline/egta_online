class StrategyController < EntitiesController
  def add_role
    @entry = klass.find(params[:id])
    @entry.role_strategy_hash[params[:role]] = []
    @entry.save!
    redirect_to url_for(:action => "show", :id => @entry.id)
  end
  
  def remove_role
    @entry = klass.find(params[:id])
    @entry.role_strategy_hash.delete params[:role]
    @entry.save!
    redirect_to url_for(:action => "show", :id => @entry.id)
  end
  
  def add_strategy
    @entry = klass.find(params[:id])
    role = params[:role]
    puts role
    puts params["#{role}_strategy"]
    @entry.add_strategy_by_name(role, params["#{role}_strategy"])
    @entry.save!
    redirect_to url_for(:action => "show", :id => @entry.id)
  end

  def remove_strategy
    @entry = klass.find(params[:id])
    role = params[:role]
    @entry.delete_strategy_by_name(role, params[:strategy_name])
    @entry.save!
    redirect_to url_for(:action => "show", :id => @entry.id)
  end
end