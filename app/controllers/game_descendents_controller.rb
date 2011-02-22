class GameDescendentsController < AnalysisController
  before_filter :find_game

  protected

  def find_game
    if params[:game_id] == nil
      params[:game_id] = Game.first.id
    end
    @game = Game.find(params[:game_id])
  end

end