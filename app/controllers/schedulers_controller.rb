class SchedulersController < ApplicationController
  # GET /schedulers
  # GET /schedulers.xml
  def index
    @schedulers = Scheduler.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @schedulers }
    end
  end

  # GET /schedulers/1
  # GET /schedulers/1.xml
  def show
    @scheduler = Scheduler.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @scheduler }
    end
  end

  # GET /schedulers/new
  # GET /schedulers/new.xml
  def new
    @scheduler = Scheduler.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @scheduler }
    end
  end

  # GET /schedulers/1/edit
  def edit
    @scheduler = Scheduler.find(params[:id])
  end

  # POST /schedulers
  # POST /schedulers.xml
  def create
    @scheduler = Scheduler.new(params[:scheduler])

    respond_to do |format|
      if @scheduler.save
        format.html { redirect_to(@scheduler, :notice => 'Scheduler was successfully created.') }
        format.xml  { render :xml => @scheduler, :status => :created, :location => @scheduler }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @scheduler.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /schedulers/1
  # PUT /schedulers/1.xml
  def update
    @scheduler = Scheduler.find(params[:id])

    respond_to do |format|
      if @scheduler.update_attributes(params[:scheduler])
        format.html { redirect_to(@scheduler, :notice => 'Scheduler was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @scheduler.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /schedulers/1
  # DELETE /schedulers/1.xml
  def destroy
    @scheduler = Scheduler.find(params[:id])
    @scheduler.destroy

    respond_to do |format|
      format.html { redirect_to(schedulers_url) }
      format.xml  { head :ok }
    end
  end
end
