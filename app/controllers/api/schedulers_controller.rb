class Api::SchedulersController < Api::BaseController
  before_filter :find_scheduler, :only => [:add_profile, :show]
  
  def index
    respond_with(ApiScheduler.all)
  end
  
  def create
    scheduler = ApiScheduler.create(params[:scheduler])
    if scheduler.valid?
      respond_with(scheduler, :location => api_scheduler_path(scheduler))
    else
      respond_with(scheduler)
    end
  end
  
  def show
    respond_with(@scheduler)
  end
  
  def find
    respond_with(ApiScheduler.where(params[:criteria]))
  end
  
  def add_profile
    proto_string = Profile.convert_to_proto_string(params[:profile_name])
    profile = Profile.find_or_create_by(simulator_id: @scheduler.simulator_id,
                                            parameter_hash: @scheduler.parameter_hash,
                                            size: Profile.size_of_profile(proto_string),
                                            proto_string: proto_string)
    if profile.valid?
      @scheduler.profile_ids << profile.id
      @scheduler.save!
      respond_with(profile, :location => profile_path(profile))
    else
      respond_with(profile)
    end
  end
  
  private
  
  def find_scheduler
    begin
      @scheduler = ApiScheduler.find(params[:id])
    rescue
      respond_with({:error => "the scheduler you were looking for could not be found"}, :status => 404, :location => nil)
    end
  end
end