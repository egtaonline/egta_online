class Api::V3::SimulatorsController < Api::V3::BaseController
  before_filter :find_object, only: [:show, :add_role, :add_strategy, :remove_role, :remove_strategy]
  before_filter :validate_role, only: [:add_role, :add_strategy, :remove_role, :remove_strategy]
  before_filter :validate_strategy, only: [:add_strategy, :remove_strategy]

  include Api::V3::RoleManipulator
end