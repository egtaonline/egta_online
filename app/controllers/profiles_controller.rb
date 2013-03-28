class ProfilesController < ApplicationController
  respond_to :html
  expose(:profile){ Profile.where(_id: params[:id]).only(:simulator_instance_id, :assignment, :sample_count, :symmetry_groups).first }
end