class StrategyController < EntitiesController
  def add_role
    @entry = klass.find(params[:id])
    if @entry.is_a?(Simulator)
      @entry.roles.find_or_create_by(name: params[:role])
      redirect_to url_for(:action => "show", :id => @entry.id)
    elsif (1..(@entry.size-(@entry.roles.collect{|r| r.count}.reduce(:+) == nil ? 0 : @entry.size-(@entry.roles.collect{|r| r.count}.reduce(:+))))).include?(params[:role_count].to_i)
      @entry.roles.create!(name: params[:role], count: params[:role_count].to_i)
      redirect_to url_for(:action => "show", :id => @entry.id)
    else
      flash[:alert] = "Number of players per role must be an integer > 0 and <= the number of unassigned players."
      render :show
    end
  end
  
  def remove_role
    @entry = klass.find(params[:id])
    @entry.roles.where(name: params[:role]).first.delete
    redirect_to url_for(:action => "show", :id => @entry.id)
  end
  
  def add_strategy
    @entry = klass.find(params[:id])
    role = params[:role]
    @entry.add_strategy_by_name(role, params["#{role}_strategy"])
    @entry.save!
    redirect_to url_for(:action => "show", :id => @entry.id)
  end

  def remove_strategy
    @entry = klass.find(params[:id])
    role = params[:role]
    @entry.delete_strategy_by_name(role, params[:strategy_name])
    @entry.save!
    redirect_to url_for(:action => "show", :id => @entry.id)
  end
end