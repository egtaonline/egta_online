class FeaturesController < ApplicationController
  respond_to :html
  
  expose(:game) { Game.find(params[:game_id]) }

  def create
    game.cv_manager.add_feature(params[:feature])
    game.save
    respond_with(game)
  end
  
  def destroy
    game.cv_manager.remove_feature(params[:id])
    game.save
    respond_with(game)
  end
end
  