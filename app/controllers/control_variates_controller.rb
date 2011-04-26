#Manages the CRUD of ControlVariates
class ControlVariatesController < GameDescendentsController
  before_filter :create_new_cv, :only => [:new, :add_feature, :remove_feature]

  def show
    @control_variate = @game.control_variates.find(params[:id])
  end

  def new
    @cv_features = []
    calculate_feature_options
  end

  def create
    @control_variate = @game.control_variates.create!(params[:control_variate])
    @control_variate.apply_cv(params[:acr][:source_id], params[:feature_names])
    redirect_to(@game, :notice => 'Adjustments have been scheduled')
  end

  def add_feature
    params[:feature_names] ||= Array.new
    @cv_features = @game.calculate_cv_features(params)
    calculate_feature_options
    respond_to do |format|
      format.js
    end
  end

  def remove_feature
    @cv_features = @game.calculate_cv_features(params, false)
    calculate_feature_options
    respond_to do |format|
      format.js
    end
  end

  def destroy
    @game.control_variates.find(params[:id]).destroy
    redirect_to(@game)
  end

  protected

  def calculate_feature_options
    @feature_options = @game.features.collect {|feature| [feature.name, feature.id]} - @cv_features
  end

  def create_new_cv
    @control_variate = ControlVariate.new
  end
end
