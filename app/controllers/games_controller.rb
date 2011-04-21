require 'net/scp'
require 'inject'
require 'stalker'
require ::Rails.root.to_s + '/lib/egat_interface'

class GamesController < AnalysisController
  before_filter :find_game, :only => [:show, :edit, :update, :add_strategy, :remove_strategy, :destroy, :robust_regret, :regret, :analysis, :rd]
  before_filter :new_game, :only => [:new, :create, :update_parameters]

  def index
    if params[:simulator_id] == nil
      params[:simulator_id] = Simulator.first.id
    end
    @simulator = Simulator.find(params[:simulator_id])
    @games = @simulator.games.paginate :per_page => 15, :page => (params[:page] || 1)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @games }
    end
  end

  def show
    @profiles = @game.profiles.paginate :per_page => 15, :page => (params[:page] || 1)
    @transformations = Array.new
    @transformations.concat(@game.control_variates)
    respond_to do |format|
      format.html # show.html.erb
      format.xml
    end
  end

  def new
    if params[:simulator_id] == nil
      params[:simulator_id] = Simulator.first.id
    end
    simulator = Simulator.find(params[:simulator_id])
    @game[:parameters] = Array.new
    YAML.load(simulator.parameters)["web parameters"].each_pair {|x, y| @game[x] = y; @game[:parameters] << x}

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @game }
      format.json  { render :json => @game }
    end
  end

  def edit
  end

  def create
    @simulator = Simulator.find(params[:sim][:simulator_id])
    @game = Game.new(params[:game])
    @game.setup_parameters(@simulator)
    @simulator.games << @game

    respond_to do |format|
      if @game.save!
        flash[:notice] = 'Game was successfully created.'
        redirect_to @game
      else
        render :action => "new"
      end
    end
  end

  def update
    respond_to do |format|
      if @game.update_attributes(params[:game])
        flash[:notice] = 'Game was successfully updated.'
        format.html { redirect_to(@game) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @game.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update_parameters
    simulator = Simulator.find(params[:simulator_id])
    @game[:parameters] = Array.new
    YAML.load(simulator.parameters)["web parameters"].each_pair {|x, y| @game[x] = y; @game[:parameters] << x}
    respond_to do |format|
      format.js
    end
  end

  def add_strategy
    @strategy = Strategy.new(:name => @game.simulator.strategies.find(params[:strategy_id]).name)
    @game.add_strategy @strategy
    @strategy_options = @game.simulator.strategies.collect do |x|
      @game.strategies.where(:name => x.name).count == 0 ? [x.name, x.id] : []
    end
    @strategy_options.delete([])
    if @game.save!
      respond_to do |format|
        format.js
      end
    end
  end

  def remove_strategy
    @strategy = @game.strategies.find params[:strategy_id]
    @game.remove_strategy @strategy
    @strategy_options = @game.simulator.strategies.collect do |x|
      @game.strategies.where(:name => x.name).count == 0 ? [x.name, x.id] : []
    end
    @strategy_options.delete([])
    if @game.save!
      respond_to do |format|
        format.js
      end
    end
  end

  def destroy
    @game.destroy

    redirect_to(games_path)
  end

  def select_simulator
    @simulator = Simulator.find(params[:simulator_id])
    @games = @simulator.games.paginate :per_page => 15, :page => (params[:page] || 1)

    respond_to do |format|
      format.js
    end
  end

  def analysis
    @profiles = @game.profiles.paginate :per_page => 15, :page => (params[:page] || 1)

    respond_to do |format|
      format.html
    end
  end

  def robust_regret
    Stalker.enqueue 'calc_regret', :game => @game
    redirect_to analysis_game_path(@game)
  end

  def regret
    Stalker.enqueue 'calc_robust_regret', :game => @game
    redirect_to  analysis_game_path(@game)
  end

  def rd
    Stalker.enqueue 'calc_replicator_dynamics', :game => @game
    redirect_to analysis_game_path(@game)
  end

  protected

  def find_game
    @game = Game.find(params[:id])
    @strategy_options = @game.simulator.strategies.collect do |x|
      @game.strategies.where(:name => x.name).count == 0 ? [x.name, x.id] : []
    end
    @strategy_options.delete([])
  end

  def new_game
    @game = Game.new
  end
end