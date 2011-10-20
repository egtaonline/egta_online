class EntitiesController < ApplicationController
  inherit_resources
  before_filter :collected, only: "index"
  
  protected

  def collected
    @collection = collection.page(params[:page]).per(20)
  end
  
  def collection
    get_collection_ivar || set_collection_ivar(end_of_association_chain.all)
  end
end