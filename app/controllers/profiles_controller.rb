class ProfilesController < AnalysisController
  # GET /profiles
  # GET /profiles.xml
  def index
    @profiles = Profile.paginate :per_page => 15, :page => (params[:page] || 1)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @profiles }
    end
  end

  # GET /profiles/1
  # GET /profiles/1.xml
  def show
    @profile = Profile.find(params[:id])

    @account_options = Account.all.collect {|s| [s.name, s.id]}
    @simulation = @profile.simulations.build :profile_id=>params[:id]

    @total_samples = @profile.samples.count
    @clean_samples = @profile.samples.clean.count

    @queued_simulations = @profile.simulations.queued.count
    @running_simulations = @profile.simulations.running.count
    @complete_simulations = @profile.simulations.complete.count
    @failed_simulations = @profile.simulations.failed.count
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @profile }
      format.json { render :json => @profile }
    end
  end

  # GET /profiles/new
  # GET /profiles/new.xml
  def new
    @profile = Profile.new
    @game_options = Game.all.collect {|s| [s.name, s.id]}
    @strategy_options = Strategy.all.collect {|s| [s.name, s.id]}

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @profile }
      format.json { render :json => @profile }
    end
  end

  # POST /profiles
  # POST /profiles.xml
  def create
    @profile = Profile.new(params[:profile])

    respond_to do |format|
      if @profile.save
        flash[:notice] = 'Profile was successfully created.'
        format.html { redirect_to([:analysis, @profile]) }
        format.xml  { render :xml => @profile, :status => :created, :location => [:analysis, @profile] }
      else
        format.html { render :action => "new" }
        @simulator_options = Simulator.all.collect {|s| [s.name, s.id]}
        @strategy_options = Strategy.all.collect {|s| [s.name, s.id]}
        format.xml  { render :xml => @profile.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /profiles/1
  # DELETE /profiles/1.xml
  def destroy
    @profile = Profile.find(params[:id])
    @profile.destroy

    respond_to do |format|
        format.html { redirect_to(:action => "index") }
        format.xml  { head :ok }
    end
  end
end
