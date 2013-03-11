class SchedulerPresenter < JsonPresenter
  def initialize(scheduler)
    @scheduler = scheduler
  end

  def to_json
    json_start+json_specialization+json_end
  end

  private

  def json_start
    "{\"_id\":\"#{@scheduler.id}\",\"name\":\"#{@scheduler.name}\",\"simulator_id\":\"#{@scheduler.simulator_id}\",\"configuration\":#{@scheduler.configuration.to_json}," <<
    "\"active\":#{@scheduler.active},\"process_memory\":#{@scheduler.process_memory},\"time_per_sample\":#{@scheduler.time_per_sample},\"size\":#{@scheduler.size}"
  end
end