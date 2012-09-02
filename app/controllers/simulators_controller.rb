class SimulatorsController < ApplicationController
  respond_to :html

  expose(:simulators){Simulator.order_by(params[:sort]+" "+params[:direction]).page(params[:page])}
  expose(:simulator)

  def create
    simulator.save
    respond_with(simulator)
  end

  def update
    simulator.save
    respond_with(simulator)
  end

  def destroy
    simulator.destroy
    respond_with(simulator)
  end

  def add_role
    simulator.add_role(params[:role])
    respond_with(simulator)
  end

  def add_strategy
    simulator.add_strategy(params[:role], params["#{params[:role]}_strategy"])
    respond_with(simulator)
  end

  def remove_role
    simulator.remove_role(params[:role])
    respond_with(simulator)
  end

  def remove_strategy
    simulator.remove_strategy(params[:role], params[:strategy_name])
    respond_with(simulator)
  end
end