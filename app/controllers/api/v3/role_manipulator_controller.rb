class Api::V3::RoleManipulatorController < Api::V3::BaseController
  before_filter :find_subject, only: [:add_role, :add_strategy, :remove_role, :remove_strategy]
  before_filter(only: [:add_role, :add_strategy, :remove_role, :remove_strategy]) { |c| c.send(:validate_param, :role) }
  before_filter(only: [:add_strategy, :remove_strategy]) { |c| c.send(:validate_param, :strategy) }

  def add_role
    @subject.add_role(params[:role], params[:count].to_i)
    respond_with(@subject)
  end

  def add_strategy
    @subject.add_strategy(params[:role], params[:strategy])
    respond_with(@subject)
  end

  def remove_role
    @subject.remove_role(params[:role])
    respond_with(@subject)
  end

  def remove_strategy
    @subject.remove_strategy(params[:role], params[:strategy])
    respond_with(@subject)
  end

  def find_subject
    begin
      model_name = params[:controller].singularize.split("/").last
      @subject = model_name.classify.constantize.find(params[:id])
    rescue
      render json: {error: "the #{model_name} you were looking for could not be found"}.to_json, status: 404
    end
  end
end