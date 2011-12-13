class SchedulersController < SimulatorSelectorController
  expose(:profiles){Kaminari.paginate_array(Profile.find(resource.profile_ids)).page(params[:page]).per(15)}
end