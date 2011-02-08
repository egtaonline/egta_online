class ProfilesController < AnalysisController
  # GET /profiles
  # GET /profiles.xml
  def index
    @game = Game.find(params[:game_id])
    @profiles = @game.profiles.paginate :per_page => 15, :page => (params[:page] || 1)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @profiles }
    end
  end

  # GET /profiles/1
  # GET /profiles/1.xml
  def show
    @game = Game.find(params[:game_id])
    @profile = @game.profiles.find(params[:id])

    @account_options = Account.all.collect {|s| [s.name, s.id]}
    @simulation = @profile.simulations.build :profile_id=>params[:id]
    @total_samples = 0
    @profile.simulations.all.each {|x| @total_samples += x.samples.count}

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
