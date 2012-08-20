class Api::V3::GenericSchedulersController < Api::V3::SchedulersController
  before_filter :find_scheduler, only: [:add_profile, :add_role, :remove_role, :remove_profile, :update, :destroy]
  before_filter :find_profile, only: :remove_profile

  def create
    # Hack to make old api compatible with new model defs
    scheduler = GenericScheduler.create(params[:scheduler])
    if scheduler.valid?
      respond_with(scheduler, location: api_v3_generic_scheduler_path(scheduler))
    else
      respond_with(scheduler)
    end
  end

  def add_role
    @scheduler.add_role(params[:role], params[:count].to_i)
  end

  def remove_role
    @scheduler.remove_role(params[:role])
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
    if params[:sample_count].to_i == 0
      respond_with({ error: "the provided sample count was either not a number or 0" }, status: 406, location: nil)
    elsif @scheduler.unassigned_player_count > 0
      respond_with({ error: "the selected scheduler has an incomplete role partition, #{@scheduler.unassigned_player_count} player(s) have not yet been assigned" }, status: 406, location: nil)
    else
      profile = @scheduler.add_profile(params[:assignment], params[:sample_count].to_i)
      logger.warn "Inspecting profile:"
      logger.warn profile.inspect
      if profile.valid?
        respond_with(profile, location: profile_path(profile))
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
      respond_with({ error: "the scheduler you were looking for could not be found" }, status: 404, location: nil)
    end
  end

  def find_profile
    begin
      @profile = Profile.find(params[:profile_id])
    rescue
      respond_with({ error: "the profile you were looking for could not be found"}, status: 404, location: nil)
    end
  end
end