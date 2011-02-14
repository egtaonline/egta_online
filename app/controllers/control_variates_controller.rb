class ControlVariatesController < AnalysisController

  def show
    @control_variate = ControlVariate.find(params[:id])
  end

  def new
    @control_variate = ControlVariate.new
    @game = Game.find(params[:game_id])
    @cv_features = []
    @feature_options = @game.features.collect {|s| [s.name, s.id]} - @cv_features
    respond_to do |format|
      format.html
    end
  end

  def create
    @game = Game.find(params[:game_id])
    @adjustment_coefficient_record = AdjustmentCoefficientRecord.new(:game_id => params[:acr][:source_id])
    @game.simulator.adjustment_coefficient_records << @adjustment_coefficient_record
    @adjustment_coefficient_record.save!
    @adjustment_coefficient_record.calculate_coefficients(params[:feature_names].collect {|x| Game.find(params[:acr][:source_id]).features.where(:name => x).first})
    @control_variates = ControlVariate.new(params[:control_variate])
    @game.control_variates << @control_variates
    @control_variates.adjustment_coefficient_record_id = @adjustment_coefficient_record.id
    @control_variates.apply_cv
    if @control_variates.save!
      respond_to do |format|
        format.html{ redirect_to(game_path(Game.find(@control_variates.destination_id)), :notice => 'Adjustments have been scheduled')}
        format.js{ redirect_to(game_path(Game.find(@control_variates.destination_id)), :notice => 'Adjustments have been scheduled')}
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
    if params[:feature_names] == nil
      params[:feature_names] = Array.new
    end
    @control_variate = ControlVariate.new
    @game = Game.find(params[:game_id])
    @feature = @game.features.find(params[:feature_id])
    features = @game.features.collect {|s| [s.name, s.id]}
    @cv_features = params[:feature_names].collect{|s| [s, @game.features.where(:name => s).first.id]}
    @cv_features << [@feature.name, @feature.id]
    @feature_options = features - @cv_features
    respond_to do |format|
      format.js
    end
  end

  def remove_feature
    @control_variate = ControlVariate.new
    @game = Game.find(params[:game_id])
    @feature = @game.features.find(params[:feature_id])
    params[:feature_names].delete("#{@feature.name}")
    features = @game.features.collect {|s| [s.name, s.id]}
    @cv_features = params[:feature_names].collect{|s| [s, @game.features.where(:name => s).first.id]}
    @feature_options = features - @cv_features
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
end
