class Api::V2::GenericSchedulersController < Api::V2::SchedulersController
  before_filter :find_scheduler, :only => [:add_profile, :remove_profile, :update, :destroy]
  before_filter :find_profile, :only => :remove_profile
  
  def create
    scheduler = GenericScheduler.create(params[:scheduler])
    if scheduler.valid?
      respond_with(scheduler, :location => api_v2_generic_scheduler_path(scheduler))
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
    puts "Adding profile"
    if params[:sample_count].to_i == 0
      respond_with({:error => "the provided sample count was either not a number or 0"}, :status => 406, :location => nil)
    else
      profile = @scheduler.add_profile(params[:profile_name], params[:sample_count].to_i)
      puts profile.errors.inspect
      if profile.valid?
        respond_with(profile, :location => profile_path(profile))
      else
        respond_with(profile)
      end
    end
  end
  
  def remove_profile
    @scheduler.remove_profile(@profile.id)
    respond_with(@scheduler)
  end
  
  private
  
  def find_scheduler
    begin
      @scheduler = GenericScheduler.find(params[:id])
    rescue
      respond_with({:error => "the scheduler you were looking for could not be found"}, :status => 404, :location => nil)
    end
  end
  
  def find_profile
    begin
      @profile = Profile.find(params[:profile_id])
    rescue
      respond_with({:error => "the profile you were looking for could not be found"}, :status => 404, :location => nil)
    end
  end
end