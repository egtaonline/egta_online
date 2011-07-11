class EntitiesController < ApplicationController
  expose(:plural_name) { params[:controller] }
  expose(:single_name) { plural_name.singularize }
  expose(:klass) { single_name.camelize.constantize }
  expose(:entries) { klass.all.page(params[:page]).per(15) }
  expose(:klass_name) { single_name.titleize }

  def index
  end

  def new
    @entry = klass.new
  end

  def create
    @entry = klass.new(params[single_name])
    if @entry.save
      flash[:notice] = "#{klass_name} was successfully created."
      redirect_to url_for(:action => "show", :id => @entry.id)
    else
      flash[:alert] = "#{klass_name} failed to save."
      render :new
    end
  end

  def edit
    @entry = klass.find(params[:id])
  end

  def update
    if @entry.update_attributes!(params[single_name])
      flash[:notice] = "#{klass_name} was successfully updated."
      redirect_to url_for(:action => "show", :id => @entry.id)
    else
      render :edit
    end
  end

  def show
    @entry = klass.find(params[:id])
  end

  def destroy
    klass.find(params[:id]).destroy
    redirect_to :action => :index
  end
end