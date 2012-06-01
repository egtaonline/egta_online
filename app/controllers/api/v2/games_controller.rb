class Api::V2::GamesController < Api::V2::BaseController
  skip_before_filter :fullness, :only => :index
  before_filter :find_object, :only => [:show, :add_role, :add_strategy, :remove_role, :remove_strategy]
  before_filter :validate_role, :only => [:add_role, :add_strategy, :remove_role, :remove_strategy]
  before_filter :validate_strategy, :only => [:add_strategy, :remove_strategy]
  before_filter :validate_role_count, :only => [:add_role]
  
  include Api::V2::RoleManipulator
  
  def add_role
    if @object.roles.where(:name => params[:role]).count > 0
      respond_with(@object, :status => 304)
    else
      @object.add_role(params[:role], params[:count].to_i)
      respond_with(@object)
    end
  end
  
  def add_strategy
    if @object.roles.where(:name => params[:role]).count == 0
      if params[:count] == nil || params[:count] == "" || params[:count].to_i == 0
        respond_with({:error => "you did not specify a count for this role"}, :status => 422, :location => nil)
      else
        @object.add_role(params[:role], params[:count].to_i)
        @object.reload
      end
    end
    if @object.roles.where(:name => params[:role]).first.strategies.include?(params[:strategy]) == false
      @object.add_strategy(params[:role], params[:strategy])
      respond_with(@object)
    else
      respond_with(@object, :status => 304)
    end
  end
  
  protected
  
  def validate_role_count
    if params[:count] == nil || params[:count] == "" || params[:count].to_i == 0
      respond_with({:error => "you did not specify a count for this role"}, :status => 422, :location => nil)
    end
  end
end