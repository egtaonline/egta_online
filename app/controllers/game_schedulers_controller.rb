class GameSchedulersController < GameDescendentsController

  def index
    @game_schedulers = @game.game_schedulers.paginate :per_page => 15, :page => (params[:page] || 1)
    @pbs_generator = PbsGenerator.find(game_scheduler.pbs_generator_id)
  end

  def show
    @game_scheduler = @game.game_schedulers.find(params[:id])
    @pbs_name = PbsGenerator.find(@game_scheduler.pbs_generator_id).name
  end

  def new
    @game_scheduler = GameScheduler.new
    @game_options = Array.new
    Simulator.all.each {|x| @game_options.concat(x.games)}
  end

  def edit
    @game_scheduler = @game.game_schedulers.find(params[:id])
  end

  def create
    @game_scheduler = GameScheduler.new(params[:game_scheduler])
    @game.game_schedulers << @game_scheduler
    if @game_scheduler.save!
      flash[:notice] = 'Game scheduler was successfully created.'
      redirect_to @game_scheduler
    else
      render :action => "new"
    end
  end

  def update
    @game_scheduler = @game.game_schedulers.find(params[:id])
    respond_to do |format|
      if @game_scheduler.update_attributes(params[:game_scheduler])
        flash[:notice] = 'Game scheduler was successfully updated.'
        format.html { redirect_to([@game,@game_scheduler]) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @game_scheduler.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @game_scheduler = @game.game_schedulers.find(params[:id])
    @game_scheduler.destroy

    respond_to do |format|
      format.html { redirect_to(game_schedulers_url) }
      format.xml  { head :ok }
    end
  end
end