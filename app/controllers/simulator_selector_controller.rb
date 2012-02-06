class SimulatorSelectorController < EntitiesController
  expose(:resource) do
    klass = resource_class.constantize
    name = controller_name.singularize
    if id = params[:id]
      klass.find(id).tap do |r|
        if request.get? == false
          params[name] = params[name].merge(params[:selector]) if params[:selector] != nil
          r.attributes = params[name]
        end
      end
    else
      params[name] = params[name].merge(params[:selector]) if params[:selector] != nil
      klass.new(params[name])
    end
  end

  def update_parameters
    @simulator = Simulator.find(params[:simulator_id])
    respond_to do |format|
      format.js {render "simulator_selector/update_parameters"}
    end
  end
end