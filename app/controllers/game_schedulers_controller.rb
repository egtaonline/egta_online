class GameSchedulersController < SchedulersController
  before_filter :merge, :only => [:create, :update]
  respond_to :html
  
  expose(:game_schedulers){GameScheduler.page(params[:page])}
  expose(:game_scheduler)
  
  def create
    game_scheduler.save
    respond_with(game_scheduler)
  end
  
  def update
    game_scheduler.save
    respond_with(game_scheduler)
  end
  
  def destroy
    game_scheduler.destroy
    respond_with(game_scheduler)
  end
  
  def add_role
    game_scheduler.add_role(params[:role], params[:role_count])
    respond_with(game_scheduler)
  end
  
  def add_strategy
    game_scheduler.add_strategy(params[:role], params["#{params[:role]}_strategy"])
    respond_with(game_scheduler)
  end
  
  def remove_role
    game_scheduler.remove_role(params[:role])
    respond_with(game_scheduler)
  end
  
  def remove_strategy
    game_scheduler.remove_strategy(params[:role], params[:strategy_name])
    respond_with(game_scheduler)
  end
  
  private 
  
  def merge
    params[:game_scheduler] = params[:game_scheduler].merge(params[:selector])
  end
end