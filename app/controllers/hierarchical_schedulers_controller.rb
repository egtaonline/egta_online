class HierarchicalSchedulersController < GameSchedulersController
  before_filter :merge, :only => [:create, :update]
  respond_to :html
  
  expose(:hierarchical_schedulers){HierarchicalScheduler.page(params[:page])}
  expose(:hierarchical_scheduler)
  
  def create
    hierarchical_scheduler.save
    respond_with(hierarchical_scheduler)
  end
  
  def update
    hierarchical_scheduler.save
    respond_with(hierarchical_scheduler)
  end
  
  def destroy
    hierarchical_scheduler.destroy
    respond_with(hierarchical_scheduler)
  end
  
  def add_role
    hierarchical_scheduler.add_role(params[:role], params[:role_count])
    respond_with(hierarchical_scheduler)
  end
  
  def add_strategy
    hierarchical_scheduler.add_strategy(params[:role], params["#{params[:role]}_strategy"])
    respond_with(hierarchical_scheduler)
  end
  
  def remove_role
    hierarchical_scheduler.remove_role(params[:role])
    respond_with(hierarchical_scheduler)
  end
  
  def remove_strategy
    hierarchical_scheduler.remove_strategy(params[:role], params[:strategy_name])
    respond_with(hierarchical_scheduler)
  end
  
  private 
  
  def merge
    params[:hierarchical_scheduler] = params[:hierarchical_scheduler].merge(params[:selector])
  end
end