class Api::V3::RoleManipulator < Api::V3::BaseController
  before_filter :find_subject, only: [:add_role, :add_strategy, :remove_role, :remove_strategy]
  before_filter :validate_role, only: [:add_role, :add_strategy, :remove_role, :remove_strategy]
  before_filter :validate_strategy, only: [:add_strategy, :remove_strategy]

  def validate_strategy
    if params[:strategy] == nil || params[:strategy] == ""
      respond_with({error: "you did not specify a strategy"}, status: 422, location: nil)
    end
  end

  def validate_role
    if params[:role] == nil || params[:role] == ""
      respond_with({error: "you did not specify a role"}, status: 422, location: nil)
    end
  end

  def add_role
    if @subject.roles.where(name: params[:role]).count > 0
      respond_with(@subject, status: 304)
    else
      @subject.add_role(params[:role], params[:count].to_i)
      respond_with(@subject)
    end
  end

  def add_strategy
    if @subject.roles.where(name: params[:role]).count == 0 || @subject.roles.where(name: params[:role]).first.strategies.include?(params[:strategy]) == false
      @subject.add_strategy(params[:role], params[:strategy])
      respond_with(@subject)
    else
      respond_with(@subject, status: 304)
    end
  end

  def remove_role
    if @subject.roles.where(name: params[:role]).count == 0
      respond_with({message: "the role did not exist"}, status: 204, location: nil)
    else
      @subject.remove_role(params[:role])
      respond_with(@subject, status: 202)
    end
  end

  def remove_strategy
    if @subject.roles.where(name: params[:role]).count == 0
      respond_with({error: "the role did not exist"}, status: 404, location: nil)
    elsif @subject.roles.where(name: params[:role]).first.strategies.include?(params[:strategy]) == false
      respond_with({message: "the role did not exist"}, status: 204, location: nil)
    else
      @subject.remove_strategy(params[:role], params[:strategy])
      respond_with(@subject)
    end
  end

  def find_subject
    begin
      model_name = params[:controller].singularize.split("/").last
      @subject = params[:controller].singularize.split("/").last.classify.constantize.find(params[:id])
    rescue
      render json: {error: "the #{model_name} you were looking for could not be found"}.to_json, status: 404
    end
  end
end