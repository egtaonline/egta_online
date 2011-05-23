class StrategyController < DocumentsController
  def add_strategy
    entry.add_strategy_by_name(params[:strategy])
    puts entry.save!
    redirect_to url_for(:action => "show", :id => entry.id)
  end

  def remove_strategy
    entry.delete_strategy_by_name params[:strategy_name]
    entry.save!
    redirect_to url_for(:action => "show", :id => entry.id)
  end
end