class EntitiesController < ApplicationController
  inherit_resources
  has_scope :page, :default => 1
end