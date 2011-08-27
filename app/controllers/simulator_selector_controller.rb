class SimulatorSelectorController < StrategyController
  def create
    @entry = klass.new(params[single_name].merge(params[:selector]))
    if @entry.save
      flash[:notice] = "#{klass_name} was successfully created."
      redirect_to url_for(:action => "show", :controller => plural_name, :id => @entry.id)
    else
      flash[:alert] = "#{klass_name} failed to save."
      render :new
    end
  end

  def update
    if @entry = klass.find(params[:id])
      @entry.update_attributes!(params[single_name].merge(params[:selector]))
      flash[:notice] = "#{klass_name} was successfully updated."
      redirect_to url_for(:action => "show", :id => @entry.id)
    else
      render :edit
    end
  end

  def update_parameters
    @simulator = Simulator.find(params[:simulator_id])
    respond_to do |format|
      format.js
    end
  end
end