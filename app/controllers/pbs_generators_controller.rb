class PbsGeneratorsController < AnalysisController
  before_filter :find_pbs, :only => [:show, :edit, :update, :destroy]
  # GET /pbs_generators
  # GET /pbs_generators.xml
  def index
    @pbs_generators = PbsGenerator.paginate :per_page => 15, :page => (params[:page] || 1)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @pbs_generators }
    end
  end

  # GET /pbs_generators/1
  # GET /pbs_generators/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @pbs_generator }
    end
  end

  # GET /pbs_generators/new
  # GET /pbs_generators/new.xml
  def new
    @pbs_generator = PbsGenerator.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @pbs_generator }
    end
  end

  # GET /pbs_generators/1/edit
  def edit
  end

  # POST /pbs_generators
  # POST /pbs_generators.xml
  def create
    @pbs_generator = PbsGenerator.new(params[:pbs_generator])

    respond_to do |format|
      if @pbs_generator.save
        flash[:notice] = 'PbsGenerator was successfully created.'
        format.html { redirect_to @pbs_generator}
        format.xml  { render :xml => @pbs_generator, :status => :created, :location => @pbs_generator }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @pbs_generator.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /pbs_generators/1
  # PUT /pbs_generators/1.xml
  def update

    respond_to do |format|
      if @pbs_generator.update_attributes(params[:pbs_generator])
        flash[:notice] = 'PbsGenerator was successfully updated.'
        format.html { redirect_to(@pbs_generator) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @pbs_generator.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /pbs_generators/1
  # DELETE /pbs_generators/1.xml
  def destroy
    @pbs_generator.destroy

    respond_to do |format|
      format.html { redirect_to pbs_generators_path}
      format.xml  { head :ok }
    end
  end

  protected

  def find_pbs
    @pbs_generator = PbsGenerator.find(params[:id])
  end
end
