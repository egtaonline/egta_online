class Api::V1::GenericSchedulersController < Api::V1::SchedulersController
  before_filter :find_scheduler, :only => [:add_profile, :update, :destroy]
  
  def create
    scheduler = GenericScheduler.create(params[:scheduler])
    if scheduler.valid?
      respond_with(scheduler, :location => api_v1_generic_scheduler_path(scheduler))
    else
      respond_with(scheduler)
    end
  end
  
  def update
    @scheduler.update_attributes(params[:scheduler])
    respond_with(@scheduler)
  end
  
  def destroy
    @scheduler.destroy
    respond_with(@scheduler)
  end
  
  def find
    respond_with(GenericScheduler.where(params[:criteria]))
  end
  
  def add_profile
    proto_string = Profile.convert_to_proto_string(params[:profile_name])
    profile = Profile.find_or_create_by(simulator_id: @scheduler.simulator_id,
                                            parameter_hash: @scheduler.parameter_hash,
                                            size: Profile.size_of_profile(proto_string),
                                            proto_string: proto_string)
    if profile.valid?
      @scheduler.profiles << profile
      @scheduler.save
      respond_with(profile, :location => profile_path(profile))
    else
      respond_with(profile)
    end
  end
  
  private
  
  def find_scheduler
    begin
      @scheduler = GenericScheduler.find(params[:id])
    rescue
      respond_with({:error => "the scheduler you were looking for could not be found"}, :status => 404, :location => nil)
    end
  end
end