class DocumentsController < ExposureController

  def index
    render "documents/index"
  end

  def new
    render "documents/new"
  end

  def create
    entry = klass.new(params[single_name])
    if entry.save!
      flash[:notice] = "#{klass_name} was successfully created."
      redirect_to url_for(:action => "show", :id => entry.id)
    else
      flash[:alert] = "#{klass_name} failed to save."
      render :action => "new"
    end
  end

  def edit
    render "documents/edit"
  end

  def update
    if entry.update_attributes!(params[single_name])
      flash[:notice] = "#{klass_name} was successfully updated."
      redirect_to url_for(:action => "show", :id => entry.id)
    else
      render :action => "edit"
    end
  end

  def show
    respond_to do |format|
      format.html {render "documents/show"}
      format.xml
    end
  end

  def destroy
    klass.find(params[:id]).destroy
    redirect_to :action => :index
  end

end