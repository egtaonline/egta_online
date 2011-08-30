class StrategyController < EntitiesController
  def add_strategy
    @entry = klass.find(params[:id])
    @entry.add_strategy_by_name params[:strategy]
    @entry.save!
    redirect_to url_for(:action => "show", :id => @entry.id)
  end

  def remove_strategy
    @entry = klass.find(params[:id])
    @entry.delete_strategy_by_name params[:strategy_name]
    @entry.save!
    redirect_to url_for(:action => "show", :id => @entry.id)
  end
end