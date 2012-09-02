class ApplicationController < ActionController::Base
  helper_method :sort_column, :sort_direction
  before_filter :authenticate_user!
  expose(:model_name){params[:controller].singularize}
  protect_from_forgery

  private

  def sort_direction
    %w[ASC DESC].include?(params[:direction]) ? params[:direction] : "ASC"
  end

  def sort_column
    (model_name.camelize.constantize.attribute_method?(params[:sort].to_s) || params[:sort].to_s == "name" || params[:sort].to_s == "sample_count") ? params[:sort] : ""
  end
end
