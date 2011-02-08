class SimulationsController < AnalysisController
  protect_from_forgery :except => [:create,:update]

  def index
    @simulations = Simulation.paginate :per_page => 15, :page => (params[:page] || 1)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @simulations }
      format.json  { render :json => @simulations }
    end
  end

  def show
    @simulation = Simulation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @simulation }
      format.json  { render :json => @simulation }
    end
  end

  def purge
    Simulation.failed.destroy_all

    redirect_to :simulations
  end

  def edit
    @simulation = Simulation.find(params[:id])
  end

  def create
    @simulation = Simulation.new(params[:simulation])

    respond_to do |format|
      if @simulation.save
        flash[:notice] = 'Simulation was successfully created.'
        format.html { redirect_to([:analysis, @simulation]) }
        format.xml  { render :xml => @simulation, :status => :created, :location => [:analysis, @simulation] }
        format.json  { render :json => @simulation }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @simulation.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @simulation = Simulation.find(params[:id])

    respond_to do |format|
      if @simulation.update_attributes(params[:simulation])
        flash[:notice] = 'Simulation was successfully updated.'
        format.html { redirect_to([:analysis, @simulation]) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @simulation.errors, :status => :unprocessable_entity }
      end
    end
  end

  def queue
    event_transition 'queue'
  end

  def fail
    event_transition 'fail'
  end

  def start
    event_transition 'start'
  end

  def finish
    event_transition 'finish'
  end

  def destroy
    @simulation = Simulation.find(params[:id])
    @simulation.destroy

    respond_to do |format|
      format.html { redirect_to(simulations_url) }
      format.xml  { head :ok }
    end
  end

  private

  def event_transition(event)
    @simulation = Simulation.find(params[:id])

    respond_to do |format|
      if @simulation.send("#{event}!")
        flash[:notice] = 'Simulation was successfully transitioned by event #{event}.'
        format.html { redirect_to([:analysis, @simulation]) }
        format.xml  { head :transitioned }
      else
        flash[:error] = 'Simulation was not successfully transitioned by event #{event}.'
        format.html { redirect_to([:analysis, @simulation]) }
        format.xml  { head :no_transitioned }
      end
    end
  end
end
