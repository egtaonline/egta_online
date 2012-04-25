class FeaturesController < ApplicationController
  respond_to :html
  
  expose(:game) { Game.find(params[:game_id]) }

  def create
    game.cv_manager.add_feature(params[:feature])
    respond_with(game)
  end
  
  def destroy
    game.cv_manager.remove_feature(params[:id])
    respond_with(game)
  end
end
  