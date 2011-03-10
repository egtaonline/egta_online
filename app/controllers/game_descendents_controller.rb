class GameDescendentsController < SimulatorDescendentsController
  before_filter :find_game

  protected

  def find_game
    if params[:game_id] == nil
      if params[:game] == nil
        params[:game_id] = @simulator.games.first == nil ? nil : @simulator.games.first.id
      else
        params[:game_id] = params[:game][:id]
      end
    end
    @game = (params[:game_id] == nil ? nil : @simulator.games.find(params[:game_id]))
  end

end