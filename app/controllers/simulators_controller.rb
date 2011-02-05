class SimulatorsController < AnalysisController
  def index
    @simulators = Simulator.all
  end

  def show
    @simulator = Simulator.find(params[:id])
    @name = Account.find(@simulator.account_id).name
  end

  def new
    @simulator = Simulator.new
  end

  def edit
    @simulator = Simulator.find(params[:id])
  end

  def create
    @simulator = Simulator.new(params[:simulator])
    if @simulator.save!
      @simulator.setup_simulator
      flash[:notice] = 'Simulator was successfully created.'
      redirect_to @simulator
    else
      render :action => "new"
    end
  end

  def update
    @simulator = Simulator.find(params[:id])
    if @simulator.update_attributes(params[:simulator])
      flash[:notice] = 'Simulator was successfully updated.'
      redirect_to @simulator
    else
      render :action => "edit"
    end
  end

  def destroy
    @simulator = Simulator.find(params[:id])
    @simulator.destroy
    redirect_to(simulators_path)
  end

end