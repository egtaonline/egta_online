class Api::V2::SimulatorsController < Api::V2::BaseController
  before_filter :find_simulator, :validate_role, :only => [:add_role, :add_strategy, :remove_role, :remove_strategy]
  before_filter :validate_strategy, :only => [:add_strategy, :remove_strategy]
  
  def add_role
    if @simulator.roles.where(:name => params[:role]).count > 0
      respond_with(@simulator, :status => 304)
    else
      @simulator.add_role(params[:role])
      respond_with(@simulator)
    end
  end
  
  def add_strategy
    if @simulator.roles.where(:name => params[:role]).count == 0 || !@simulator.roles.where(:name => params[:role]).first.strategies.include?(params[:strategy])
      @simulator.add_strategy(params[:role], params[:strategy])
      respond_with(@simulator)
    else
      respond_with(@simulator, :status => 304)
    end
  end
  
  def remove_role
    if @simulator.roles.where(:name => params[:role]).count == 0
      respond_with({:message => "the role did not exist"}, :status => 204, :location => nil)
    else
      @simulator.remove_role(params[:role])
      respond_with(@simulator, :status => 202)
    end
  end
  
  def remove_strategy
    if @simulator.roles.where(:name => params[:role]).count == 0
      respond_with({:error => "the role did not exist"}, :status => 404, :location => nil)
    elsif !@simulator.roles.where(:name => params[:role]).first.strategies.include?(params[:strategy])
      respond_with({:message => "the role did not exist"}, :status => 204, :location => nil)
    else
      @simulator.remove_strategy(params[:role], params[:strategy])
      respond_with(@simulator)
    end
  end
  
  protected
  
  def find_simulator
    begin
      @simulator = Simulator.find(params[:id])
    rescue
      respond_with({:error => "the simulator you were looking for could not be found"}, :status => 404, :location => nil)
    end
  end
  
  def validate_strategy
    if params[:strategy] == nil || params[:strategy] == ""
      respond_with({:error => "you did not specify a strategy"}, :status => 422, :location => nil)
    end
  end
  
  def validate_role
    if params[:role] == nil || params[:role] == ""
      respond_with({:error => "you did not specify a role"}, :status => 422, :location => nil)
    end
  end
end