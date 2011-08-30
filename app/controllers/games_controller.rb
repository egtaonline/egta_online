class GamesController < SimulatorSelectorController
  def show
    @entry = klass.find(params[:id])
    respond_to do |format|
      format.html
      # come back and speed up sample issue
      format.xml { @profiles = Profile.where(:proto_string => @entry.strategy_regex).find(@entry.profile_ids).select {|p| p.sampled == true } }
    end
  end
end
