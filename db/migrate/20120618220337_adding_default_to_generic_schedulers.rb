class AddingDefaultToGenericSchedulers < Mongoid::Migration
  def self.up
    GenericScheduler.all.each do |g|
      val = g.sample_hash.values.uniq.min
      g.update_attribute(:default_samples, val == nil ? 0 : val)
      p g.default_samples
    end
  end

  def self.down
  end
end