class Api::V2::GamesController < Api::V2::BaseController
  skip_before_filter :fullness, :only => :index
end