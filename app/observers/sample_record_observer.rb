class SampleRecordObserver < Mongoid::Observer
  def after_create(sample_record)
    profile = sample_record.profile
    profile.inc(:sample_count, 1)
  end
  
  def before_destroy(sample_record)
    profile = sample_record.profile
    profile.update_attribute(:sample_count, profile.sample_count-1)
  end
end