#Controls the CRUD of Features
class FeaturesController < GameDescendentsController
  before_filter :find_feature, :only => [:show, :edit, :update, :destroy]

  def index
    @features = @game.features.all
  end

  def show
  end

  def new
    @feature = Feature.new
    @game_options = Game.all.collect {|feature| [feature.name, feature.id]}
  end

  def edit
  end

  def create
    @feature = @game.features.create(params[:feature])

    flash[:notice] = 'Feature was successfully created.'
    redirect_to([@game, @feature])
  end

  def update
    if @feature.update_attributes(params[:feature])
      flash[:notice] = 'Feature was successfully updated.'
      redirect_to([@game, @feature])
    else
      render :action => "edit"
    end
  end

  def destroy
    @feature.destroy
    redirect_to(features_url)
  end

  protected

  def find_feature
    @feature = @game.features.find(params[:id])
  end

end
