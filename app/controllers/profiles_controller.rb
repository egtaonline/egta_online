class ProfilesController < ApplicationController
  respond_to :html
  expose(:profile){ Profile.where(_id: params[:id]).only(:configuration, :simulator_id, :assignment, :sample_count, :symmetry_groups).first }
end