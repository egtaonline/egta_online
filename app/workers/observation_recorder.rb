class ObservationRecorder
  include Sidekiq::Worker
  sidekiq_options unique: true

  def perform(location, profile_id)

  end
end