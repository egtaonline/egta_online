module Sampling
  module Simple
    extend ActiveSupport::Concern

    included do
      validates_numericality_of :default_samples, :size, greater_than: 0
    end

    def required_samples(profile)
      profile.scheduler_ids.include?(self.id) ? default_samples : 0
    end
  end
end