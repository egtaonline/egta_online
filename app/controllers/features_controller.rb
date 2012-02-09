class FeaturesController < ApplicationController
  respond_to :html
  
  expose(:game) { Game.find(params[:game_id]) }

  def create
    game.features.create(params)
    respond_with(game)
  end
  
  def destroy
    game.features.find(params[:id]).destroy
    respond_with(game)
  end
end
  