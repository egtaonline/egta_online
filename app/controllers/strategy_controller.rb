class StrategyController < EntitiesController
  before_filter :set_profiles, :only => [:show, :add_strategy, :remove_strategy]

  def add_strategy
    @entry.add_strategy_by_name params[:strategy]
    @entry.save!
    redirect_to url_for(:action => "show", :id => @entry.id)
  end

  def remove_strategy
    @entry.delete_strategy_by_name params[:strategy_name]
    @entry.save!
    redirect_to url_for(:action => "show", :id => @entry.id)
  end

  protected

  def set_profiles
    @entry = klass.find(params[:id])
    @profiles = @entry.profiles.page(params[:page]).per(20)
  end
end