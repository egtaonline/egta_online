class ProfilesController < ApplicationController
  respond_to :html
  expose(:profile)
end