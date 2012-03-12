class SubgameDeviationSchedulersController < SchedulersController
  before_filter :merge, :only => [:create, :update]
  respond_to :html
  
  expose(:subgame_deviation_schedulers){SubgameDeviationScheduler.page(params[:page])}
  expose(:subgame_deviation_scheduler)
end