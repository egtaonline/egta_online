class HierarchicalSchedulersController < GameSchedulersController
  defaults :resource_class => HierarchicalScheduler, :collection_name => 'schedulers', :instance_name => 'scheduler'
end