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
    puts params[:simulator]
    puts params[:serv]
    @simulator = Simulator.create(params[:simulator])
    params[:serv][:server_proxy_ids].each {|host| @simulator.server_proxies << ServerProxy.where(:host => host).first}
    if @simulator.save!
      flash[:notice] = @simulator.setup_simulator
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