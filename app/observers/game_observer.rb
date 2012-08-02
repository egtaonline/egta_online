class GameObserver < Mongoid::Observer
  def after_create(game)
    Resque.enqueue(ProfileGatherer, game.id)
  end
  
  def before_validation(game)
    game.simulator_fullname = game.simulator.fullname
  end
end
