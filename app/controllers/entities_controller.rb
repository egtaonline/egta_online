class EntitiesController < ApplicationController
  inherit_resources
  before_filter :collected, only: "index"
  
  protected
  
  def collected
    @collection ||= end_of_association_chain.page(params[:page])
  end
end