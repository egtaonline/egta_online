class ProfilesController < ApplicationController
  respond_to :html, :json
  expose(:profile)
end