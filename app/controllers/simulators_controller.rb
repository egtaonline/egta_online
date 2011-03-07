class SimulatorsController < AnalysisController
  before_filter :find_simulator, :except => [:index, :new, :create]
  def index
    @simulators = Simulator.all
  end

  def show
  end

  def new
    @simulator = Simulator.new
  end

  def edit
  end

  def create
    @simulator = Simulator.create(params[:simulator])
    if @simulator.save!
      @simulator.setup_simulator params[:account][:account_id]
      flash[:notice] = 'Simulator was successfully created.'
      redirect_to @simulator
    else
      render :action => "new"
    end
  end

  def update
    if @simulator.update_attributes(params[:simulator])
      flash[:notice] = 'Simulator was successfully updated.'
      redirect_to @simulator
    else
      render :action => "edit"
    end
  end

  def destroy
    @simulator.destroy
    redirect_to(simulators_path)
  end

  def add_strategy
    @simulator.strategies.create(:name => params[:strategy])

    respond_to do |format|
      format.js
    end
  end

  def remove_strategy
    @simulator.strategies.find(params[:strategy_id]).destroy

    respond_to do |format|
      format.js
    end
  end

  protected

  def find_simulator
    @simulator = Simulator.find(params[:id])
  end
end