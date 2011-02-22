class SimulatorsController < AnalysisController
  before_filter :find_simulator, :except => [:index, :new, :create]
  def index
    @simulators = Simulator.all
  end

  def show
    @name = Account.find(@simulator.account_id).name
  end

  def new
    @simulator = Simulator.new
  end

  def edit
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

  protected

  def find_simulator
    @simulator = Simulator.find(params[:id])
  end
end