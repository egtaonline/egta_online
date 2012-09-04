class SimulationsController < ApplicationController
  respond_to :html

  expose(:simulations){ Simulation.order_by("#{sort_column} #{sort_direction}").page(params[:page]) }
  expose(:simulation)

  private

  def default
    "_id"
  end
end
