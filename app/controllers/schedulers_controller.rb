class SchedulersController < ApplicationController
  respond_to :html, :json
  before_filter :merge, only: [:create, :update]

  # These exposures are so that we can treat all different schedulers as scheduler in views, allowing view reuse where it's helpful
  expose(:schedulers){model_name.classify.constantize.order_by("#{sort_column} #{sort_direction}").page(params[:page])}
  expose(:scheduler) do
    proxy = model_name.classify.constantize
    if id = params["#{model_name}_id"] || params[:id]
      proxy.find(id).tap do |r|
        r.attributes = params[model_name] unless request.get?
      end
    else
      proxy.new(params[model_name])
    end
  end

  expose(:profiles){ Profile.where(scheduler_ids: params[:id]).order_by("#{sort_column} #{sort_direction}").only(:assignment, :sample_count, :scheduler_ids).page(params[:page]) }

  def create
    scheduler = model_name.classify.constantize.create_with_simulator_instance(params[model_name])
    respond_with(scheduler)
  end

  def update
    scheduler = model_name.classify.constantize.find(params[:id]).update_with_simulator_instance(params[model_name])
    respond_with(scheduler)
  end

  def destroy
    scheduler.destroy
    respond_with(scheduler)
  end

  def add_role
    scheduler.add_role(params[:role], params[:role_count])
    respond_with(scheduler)
  end

  def remove_role
    scheduler.remove_role(params[:role])
    respond_with(scheduler)
  end

  def page_profiles
  end

  def create_game_to_match
    respond_with(scheduler.create_game_to_match)
  end

  def update_configuration
    @simulator = Simulator.find(params[:simulator_id])
    respond_to do |format|
      format.js {render "simulator_selector/update_configuration"}
    end
  end

  private

  def merge
    params[model_name] = params[model_name].merge(params[:selector])
  end

  def default
    "name"
  end

  def sort_column
    if params[:id]
      params[:sort] ||= "assignment"
      Profile.attribute_method?(params[:sort]) ? params[:sort] : "assignment"
    else
      super
    end
  end
end