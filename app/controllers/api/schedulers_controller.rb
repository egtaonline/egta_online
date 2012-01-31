class Api::SchedulersController < Api::BaseController
  respond_to :json
  before_filter :find_scheduler, :only => :add_profile
  
  def index
    respond_with(ApiScheduler.all)
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