class GenericSchedulerPresenter
  def initialize(scheduler)
    @scheduler = scheduler
  end

  def to_json
    "{\"_id\":\"#{@scheduler.id}\",\"name\":\"#{@scheduler.name}\",\"simulator_id\":\"#{@scheduler.simulator_id}\",\"configuration\":#{@scheduler.configuration.to_json}," <<
    "\"active\":#{@scheduler.active},\"process_memory\":#{@scheduler.process_memory},\"time_per_sample\":#{@scheduler.time_per_sample},\"size\":#{@scheduler.size}}," <<
    "\"roles\":[#{@scheduler.roles.collect{ |role| "{\"name\":\"#{role.name}\",\"count\":#{role.count}}" }.join(",") }]," <<
    "\"samples_per_simulation\":#{@scheduler.samples_per_simulation},\"nodes\":#{@scheduler.nodes},\"sample_hash\":#{sample_hash.to_json}"
  end

  private

  def sample_hash
    shash = {}
    Profile.where(:_id.in => @scheduler.sample_hash.keys).only(:sample_count).each do |profile|
      local_hash = {}
      local_hash["requested_samples"] = @scheduler.sample_hash[profile["_id"].to_s]
      local_hash["sample_count"] = profile["sample_count"]
      shash[profile["_id"]] = local_hash
    end
    shash
  end
end