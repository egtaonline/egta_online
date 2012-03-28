module Api::V2::RoleManipulator  
  def add_role
    if @object.roles.where(:name => params[:role]).count > 0
      respond_with(@object, :status => 304)
    else
      @object.add_role(params[:role])
      respond_with(@object)
    end
  end
  
  def add_strategy
    if @object.roles.where(:name => params[:role]).count == 0 || @object.roles.where(:name => params[:role]).first.strategies.where(:name => params[:strategy]).count == 0
      @object.add_strategy(params[:role], params[:strategy])
      respond_with(@object)
    else
      respond_with(@object, :status => 304)
    end
  end
  
  def remove_role
    if @object.roles.where(:name => params[:role]).count == 0
      respond_with({:message => "the role did not exist"}, :status => 204, :location => nil)
    else
      @object.remove_role(params[:role])
      respond_with(@object, :status => 202)
    end
  end
  
  def remove_strategy
    if @object.roles.where(:name => params[:role]).count == 0
      respond_with({:error => "the role did not exist"}, :status => 404, :location => nil)
    elsif @object.roles.where(:name => params[:role]).first.strategies.where(:name => params[:strategy]).count == 0
      respond_with({:message => "the role did not exist"}, :status => 204, :location => nil)
    else
      @object.remove_strategy(params[:role], params[:strategy])
      respond_with(@object)
    end
  end
  
  protected
  
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