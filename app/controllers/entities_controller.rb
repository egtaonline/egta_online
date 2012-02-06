class EntitiesController < ApplicationController
  respond_to :html
  expose(:resource_class){controller_name.classify}
  expose(:resource) do
    klass = resource_class.constantize
    name = controller_name.singularize
    if id = params[:id]
      klass.find(id).tap do |r|
        if request.get? == false
          r.attributes = params[name]
        end
      end
    else
      klass.new(params[name])
    end
  end
  expose(:resources){resource_class.constantize.page(params[:page])}
  expose(:resources_url){"/#{controller_name}"}
  expose(:resource_url){"/#{controller_name}/#{params[:id]}"}
  expose(:edit_resource_url){resource_url+"/edit"}

  def create
    resource.save
    respond_with(resource)
  end

  def update
    resource.save
    respond_with(resource)
  end

  def destroy
    resource.destroy
    respond_with(resource)
  end
end