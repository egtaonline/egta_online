class Api::V3::ProfilesController < Api::V3::BaseController
  def show
    begin
      render json: ProfilePresenter.new(Profile.find(params[:id])).to_json, status: 200
    rescue
      render json: {error: "the profile you were looking for could not be found"}.to_json, status: 404
    end
  end
end