class GamesController < SimulatorSelectorController
  def show
    @entry = klass.find(params[:id])
    respond_to do |format|
      format.html { @profiles = @entry.profiles.page(params[:page]).order("name DESC").per(20) }
      format.xml { @profiles = @entry.profiles.order("name DESC") }
    end
  end
end