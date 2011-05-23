class GamesController < StrategyController
  def update_parameters
    respond_to do |format|
      format.js
    end
  end
end