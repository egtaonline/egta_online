class GamesController < SimulatorSelectorController
  def show
    @entry = klass.find(params[:id])
    respond_to do |format|
      format.html
      format.xml { @profiles = @entry.profiles.where(:proto_string => @entry.strategy_regex).to_a.select {|p| p.sampled == true } }
    end
  end
end
