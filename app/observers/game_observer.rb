class GameObserver < Mongoid::Observer
  def before_validation(game)
    game.simulator_fullname = game.simulator.fullname
  end
end
