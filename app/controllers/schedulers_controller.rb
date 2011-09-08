class SchedulersController < SimulatorSelectorController
  before_filter :find_profiles, only: "show"
    
  protected
  
  def find_profiles
    @entry = klass.find(params[:id])
    @profiles = Kaminari.paginate_array(Profile.find(@entry.profile_ids)).page(params[:page]).per(15)
  end
end