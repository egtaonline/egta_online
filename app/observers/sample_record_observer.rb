class SampleRecordObserver < Mongoid::Observer
  def after_create(sample_record)
    sample_record.profile.inc(:sample_count, 1)
  end
  
  def around_destroy(sample_record)
    profile = sample_record.profile
    yield
    profile.inc(:sample_count, -1)
  end
end