class GamesController < AnalysisController
  def index
  end

  def show
    @parameters = RunTimeConfiguration.find(params[:search][:run_time_configuration_id]).name
    @profiles = Profile.where(params[:search]).order("name DESC").page(params[:page]).per(20)
  end
end