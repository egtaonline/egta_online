class GamesController < StrategyController
  expose(:profiles) { entry.profiles.page(params[:page]).per(15) }

  def update_parameters
    respond_to do |format|
      format.js
    end
  end
end