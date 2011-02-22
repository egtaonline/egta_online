class SimulationsController < GameDescendentsController
  before_filter :gather_simulations, :only => [:index, :update_game]

  def index
  end

  def show
    @username = Account.find(@simulation.account_id).username
    @simulation = @game.simulations.find(params[:id])
  end

  def purge
    @game.simulations.failed.destroy_all
    redirect_to :simulations
  end

  def update_game
    respond_to do |format|
      format.js
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
    @simulation = @game.simulations.find(params[:id])
    @simulation.destroy

    redirect_to([@game, simulations_url])
  end

  private

  def gather_simulations
    @simulations = @game.simulations.order_by(:created_at.desc).paginate :per_page => 15, :page => (params[:page] || 1)
  end

  def event_transition(event)
    @simulation = @game.simulations.find(params[:id])

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
