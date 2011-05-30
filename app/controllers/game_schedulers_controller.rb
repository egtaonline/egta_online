class GameSchedulersController < StrategyController
  def show
    @profiles = entry.profiles.order("name DESC").page(params[:page]).per(20)
    render "documents/show"
  end
end