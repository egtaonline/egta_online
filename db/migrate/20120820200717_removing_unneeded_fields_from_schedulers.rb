class RemovingUnneededFieldsFromSchedulers < Mongoid::Migration
  def self.up
    Scheduler.where(:max_samples.exists => true).unset(:max_samples)
    Scheduler.all.unset(:profile_ids)
    Scheduler.where(:run_time_configuration_id.exists => true).unset(:run_time_configuration_id)
    Scheduler.where(:jobs_per_request.exists => true).unset(:jobs_per_request)
  end

  def self.down
  end
end