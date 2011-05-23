#Authenticates users
class AnalysisController < ApplicationController
  def robust_regret
    Stalker.enqueue 'calc_regret', :game => @game
    redirect_to analysis_game_path(@game)
  end

  def regret
    Stalker.enqueue 'calc_robust_regret', :game => @game
    redirect_to  analysis_game_path(@game)
  end

  def rd
    Stalker.enqueue 'calc_replicator_dynamics', :game => @game
    redirect_to analysis_game_path(@game)
  end
end
