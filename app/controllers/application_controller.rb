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
    params[:sort] ||= default
    model_name.camelize.constantize.attribute_method?(params[:sort]) ? params[:sort] : default
  end
end
