class SchedulerPresenter
  def initialize(scheduler)
    @scheduler = scheduler
  end

  def to_json
    "{\"_id\":\"#{@scheduler.id}\",\"name\":\"#{@scheduler.name}\",\"simulator_id\":\"#{@scheduler.simulator_id}\",\"configuration\":#{@scheduler.configuration.to_json}," <<
    "\"active\":#{@scheduler.active},\"process_memory\":#{@scheduler.process_memory},\"time_per_sample\":#{@scheduler.time_per_sample},\"size\":#{@scheduler.size}," <<
    "\"default_samples\":#{@scheduler.default_samples},\"roles\":[#{@scheduler.roles.collect{ |role| "{\"name\":\"#{role.name}\",\"count\":#{role.count},\"strategies\":#{role.strategies.to_json}}" }.join(",") }]," <<
    "\"samples_per_simulation\":#{@scheduler.samples_per_simulation},\"nodes\":#{@scheduler.nodes},\"sample_set\":#{sample_hash.to_json}}"
  end

  private

  def sample_hash
    shash = {}
    puts "here"
    Profile.collection.find(scheduler_ids: @scheduler.id).select(sample_count: 1)
  end
end