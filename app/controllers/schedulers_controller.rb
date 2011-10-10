class SchedulersController < EntitiesController
  include SimulatorSelectorController
  before_filter :find_profiles, only: "show"
    
  protected
  
  def find_profiles
    @profiles = Kaminari.paginate_array(Profile.find(resource.profile_ids)).page(params[:page]).per(15)
  end
end