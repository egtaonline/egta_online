class ControlVariatesController < AnalysisController

  def show
    @control_variate = ControlVariate.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @control_variate }
    end
  end

  # GET /analysis/control_variates/new
  # GET /analysis/control_variates/new.xml
  def new
    @variable_holder = Array.new
    @control_variate = ControlVariate.new
    @game = Game.find(params[:game_id])
    @cv_features = session_features.collect{|s| [@game.features.find(s).name, s]}
    @feature_options = @game.features.collect {|s| [s.name, s.id]} - @cv_features
    @source = session_source
    respond_to do |format|
      format.html
    end
  end

  def create
    @game = Game.find(params[:game_id])
    @adjustment_coefficient_record = AdjustmentCoefficientRecord.new
    @game.adjustment_coefficient_records << @adjustment_coefficient_record
    @game.simulator.adjustment_coefficient_records << @adjustment_coefficient_record
    @adjustment_coefficient_record.save!
    @adjustment_coefficient_record.calculate_coefficients(session_features)


    @control_variates = ControlVariate.new(params[:control_variate])
    @game.control_variates << @control_variates
    if @control_variates.save!
      respond_to do |format|
        format.html{ redirect_to(game_control_variate_path(@control_variate), :notice => 'Adjustments have been scheduled')}
      end
    end
  end

  # GET /analysis/control_variates/1/edit
  def edit
    @control_variate = ControlVariate.find(params[:id])
  end

  # PUT /analysis/control_variates/1
  # PUT /analysis/control_variates/1.xml
  def update
    @control_variate = ControlVariate.find(params[:id])
    adjustments = Hash.new
    params[:control_variate].each_pair do |x, y|
      if @control_variate.attributes.has_key? x
        @control_variate[x] = y
      else
        adjustments[x] = y
      end
    end
    @control_variate[:adjustment_hash] = adjustments
    respond_to do |format|
      if @control_variate.update_attributes(params[:control_variate])
        @control_variate.perform_adjustments
        format.html {redirect_to(game_control_variate_path(@control_variate), :notice => 'Adjustments have been scheduled.')}
      end
    end
  end

  def add_feature
    @control_variate = ControlVariate.new
    @game = Game.find(params[:game_id])
    @feature = @game.features.find(params[:feature_id])
    session_features << @feature.id
    features = @game.features.collect {|s| [s.name, s.id]}
    @cv_features = session_features.collect{|s| [@game.features.find(s).name, s]}
    @feature_options = features - @cv_features
    @source = session_source
    respond_to do |format|
      format.js
    end
  end

  def remove_feature
    @control_variate = ControlVariate.new
    @game = Game.find(params[:game_id])
    @feature = @game.features.find(params[:feature_id])
    session_features.delete(@feature.id)
    features = @game.features.collect {|s| [s.name, s.id]}
    @cv_features = session_features.collect{|s| [@game.features.find(s).name, s]}
    @feature_options = features - @cv_features
    @source = session_source
    respond_to do |format|
      format.js
    end
  end

  def update_choice
    @game = Game.find(params[:game_id])
    @control_variate = ControlVariate.new
    session_source = params[:source]
    features = @game.features.collect {|s| [s.name, s.id]}
    @cv_features = session_features.collect{|s| [@game.features.find(s).name, s]}
    @feature_options = features - @cv_features
    @source = session_source
    respond_to do |format|
      format.js
    end
  end
  # DELETE /analysis/control_variates/1
  # DELETE /analysis/control_variates/1.xml
  def destroy
    @control_variate = ControlVariate.find(params[:id])
    @control_variate.destroy

    respond_to do |format|
      format.html { redirect_to(control_variates_url) }
      format.xml  { head :ok }
    end
  end

  private

  def session_source
    session[:source] ||= "0"
  end

  def session_features
    session[:features] ||= Array.new
    @game = Game.find(params[:game_id])
    session[:features].each do |x|
      if @game.features.find(x) == nil
        session[:features] = Array.new
        break
      end
    end
  end
end
