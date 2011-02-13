class FeaturesController < AnalysisController

  def index
    @features = Feature.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @features }
      format.json  { render :json => @features }
    end
  end

  def show
    @feature = Feature.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @feature }
      format.json  { render :json => @feature }
    end
  end

  def new
    @feature = Feature.new
    @game_options = Game.all.collect {|s| [s.name, s.id]}
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @feature }
      format.json  { render :json => @feature }
    end
  end

  def edit
    @feature = Feature.find(params[:id])
  end

  def create
    @feature = Feature.new(params[:feature])
    @game_options = Game.all.collect {|s| [s.name, s.id]}
    respond_to do |format|
      if @feature.save
        flash[:notice] = 'Feature was successfully created.'
        format.html { redirect_to([@game, @feature]) }
        format.xml  { render :xml => @feature, :status => :created, :location => [:analysis, @feature] }
        format.json  { render :json => @feature }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @feature.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @feature = Feature.find(params[:id])

    respond_to do |format|
      if @feature.update_attributes(params[:feature])
        flash[:notice] = 'Feature was successfully updated.'
        format.html { redirect_to([:analysis, @feature]) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @feature.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @feature = Feature.find(params[:id])
    @feature.destroy

    respond_to do |format|
      format.html { redirect_to(analysis_features_url) }
      format.xml  { head :ok }
    end
  end

end
