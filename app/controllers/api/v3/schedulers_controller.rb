class Api::V3::SchedulersController < Api::V3::BaseController
  def show
    begin
      render json: NonGenericPresenter.new(Scheduler.find(params[:id])).to_json, status: 200
    rescue
      render json: {error: "the scheduler you were looking for could not be found"}.to_json, status: 404
    end
  end
end