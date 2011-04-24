class GameSchedulersController < AnalysisController

  def index
    @game_schedulers = GameScheduler.paginate :per_page => 15, :page => (params[:page] || 1)
  end

  def show
    @game_scheduler = GameScheduler.find(params[:id])
  end

  def new
    @game_scheduler = GameScheduler.new
  end

  def edit
    @game_scheduler = GameScheduler.find(params[:id])
  end

  def create
    @game_scheduler = GameScheduler.create(params[:game_scheduler])
    @game = Game.find(params[:parm][:game_id])
    @game.game_schedulers << @game_scheduler
    if @game_scheduler.save!
      flash[:notice] = 'Game scheduler was successfully created.'
      redirect_to @game_scheduler
    else
      render :action => "new"
    end
  end

  def update
    @game_scheduler = GameScheduler.find(params[:id])
    respond_to do |format|
      if @game_scheduler.update_attributes(params[:game_scheduler])
        flash[:notice] = 'Game scheduler was successfully updated.'
        format.html { redirect_to(@game_scheduler) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @game_scheduler.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @game_scheduler = GameScheduler.find(params[:id])
    @game_scheduler.destroy

    respond_to do |format|
      format.html { redirect_to(game_schedulers_url) }
      format.xml  { head :ok }
    end
  end
end