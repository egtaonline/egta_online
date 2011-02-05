class GameSchedulersController < AnalysisController

  def index
    @game_schedulers = Array.new
    Simulator.all.each do |x|
      x.games.all.each {|y| @game_schedulers.concat(y.game_schedulers)}
    end
    @game_schedulers = @game_schedulers.paginate :per_page => 15, :page => (params[:page] || 1)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @game_schedulers }
      format.json  { render :json => @game_schedulers }
    end
  end

  def show
    @simulator = Simulator.find(params[:simulator_id])
    @game = @simulator.games.find(params[:game_id])
    @game_scheduler = @game.game_schedulers.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @game_scheduler }
      format.json  { render :json => @game_scheduler }
    end
  end

  def new
    @game_scheduler = GameScheduler.new
    @game_options = Array.new
    Simulator.all.each {|x| @game_options.concat(x.games)}
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @game_scheduler }
      format.json  { render :json => @game_scheduler }
    end
  end

  def edit
    @simulator = Simulator.find(params[:simulator_id])
    @game = @simulator.games.find(params[:game_id])
    @game_scheduler = @game.game_schedulers.find(params[:id])
  end

  def create
    ids = params[:parm][:game_info]
    @simulator = Simulator.find(ids.split(":")[0])
    @game = @simulator.games.find(ids.split(":")[1])
    @game_scheduler = GameScheduler.new(params[:game_scheduler])
    @game.game_schedulers << @game_scheduler
    respond_to do |format|
      if @game_scheduler.save!
        flash[:notice] = 'Game scheduler was successfully created.'
        format.html { redirect_to [@simulator, @game, @game_scheduler] }
        format.xml  { render :xml => @game_scheduler, :status => :created, :location => [@simulator, @game, @game_scheduler] }
        format.json  { render :json => @game_scheduler }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @game_scheduler.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @simulator = Simulator.find(params[:simulator_id])
    @game = @simulator.games.find(params[:game_id])
    @game_scheduler = @game.game_schedulers.find(params[:id])
    respond_to do |format|
      if @game_scheduler.update_attributes(params[:game_scheduler])
        flash[:notice] = 'Game scheduler was successfully updated.'
        format.html { redirect_to([:analysis, @game_scheduler]) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @game_scheduler.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @simulator = Simulator.find(params[:simulator_id])
    @game = @simulator.games.find(params[:game_id])
    @game_scheduler = @game.game_schedulers.find(params[:id])
    @game_scheduler.destroy

    respond_to do |format|
      format.html { redirect_to(game_schedulers_url) }
      format.xml  { head :ok }
    end
  end
end
