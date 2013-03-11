class NonGenericSchedulerPresenter < SchedulerPresenter
  def json_specialization
    ",\"default_samples\":#{@scheduler.default_samples},\"roles\":[#{@scheduler.roles.collect{ |role| "{\"name\":\"#{role.name}\",\"count\":#{role.count},\"strategies\":#{role.strategies.to_json}}" }.join(",") }]," <<
    "\"samples_per_simulation\":#{@scheduler.samples_per_simulation},\"nodes\":#{@scheduler.nodes},\"sample_set\":#{sample_set.to_json}"
  end

  private

  def sample_set
    Profile.where(scheduler_ids: @scheduler.id).only(:sample_count)
  end
end