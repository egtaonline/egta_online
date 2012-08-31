module Api::V3::RoleManipulator
  protected

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
end