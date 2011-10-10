class GameSchedulersController < SchedulersController
  defaults :resource_class => GameScheduler, :collection_name => 'schedulers', :instance_name => 'scheduler'
end