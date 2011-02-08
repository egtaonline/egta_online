require 'net/scp'
require 'inject'
require 'stalker'

class GamesController < AnalysisController

  def index
    @games = Game.paginate :per_page => 15, :page => (params[:page] || 1)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @games }
    end
  end

def show
  @game = Game.find(params[:id])
  @profiles = @game.profiles.paginate :per_page => 15, :page => (params[:page] || 1)
  respond_to do |format|
    format.html # show.html.erb
    format.xml
  end
end

def new
  @game = Game.new
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
  @game = Game.find(params[:id])
end

def create
  simulator = Simulator.find(params[:game][:simulator])
  @game = Game.new
  @game[:parameters] = Array.new
  YAML.load(simulator.parameters)["web parameters"].each_pair {|x, y| @game[x] = y; @game[:parameters] << x}
  @game.update_attributes(params[:game])

  respond_to do |format|
    if @game.save
      flash[:notice] = 'Game was successfully created.'
      format.html { redirect_to @game }
      format.xml  { render :xml => @game, :status => :created, :location => @game }
      format.json  { render :json => @game }
    else
      format.html { render :action => "new" }
      format.xml  { render :xml => @game.errors, :status => :unprocessable_entity }
    end
  end
end

def update
  @game = Game.find(params[:id])
  respond_to do |format|
    if @game.update_attributes(params[:game])
      flash[:notice] = 'Game was successfully updated.'
      format.html { redirect_to([@game.simulator,@game]) }
      format.xml  { head :ok }
    else
      format.html { render :action => "edit" }
      format.xml  { render :xml => @game.errors, :status => :unprocessable_entity }
    end
  end
end

def update_parameters
  @game = Game.new
  simulator = Simulator.find(params[:simulator_id])
  @game[:parameters] = Array.new
  YAML.load(simulator.parameters)["web parameters"].each_pair {|x, y| @game[x] = y; @game[:parameters] << x}
  respond_to do |format|
    format.js
  end
end

def add_strategy
  @game = Simulator.find(params[:simulator_id]).games.find(params[:id])
  @strategy = Strategy.new(:name => params[:strategy])
  @game.add_strategy @strategy
  if @game.save!
    respond_to do |format|
      format.js
    end
  end
end

def remove_strategy
  @game = Simulator.find(params[:simulator_id]).games.find(params[:id])
  @strategy = @game.strategies.find params[:strategy_id]
  @game.remove_strategy @strategy
  if @game.save!
    respond_to do |format|
      format.js
    end
  end
end

def destroy
  @game = Game.find(params[:id])
  @game.destroy

  redirect_to(games_path)
end

end
