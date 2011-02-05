class PbsGenerator
  include Mongoid::Document

  field :process_memory, :type => Integer
  field :qos
  field :time_per_sample, :type => Integer
  field :jobs_per_request, :type => Integer

  validates_presence_of :process_memory
  validates_numericality_of :process_memory, :only_integer => true

  validates_presence_of :time_per_sample
  validates_numericality_of :time_per_sample, :only_integer => true

  validates_presence_of :jobs_per_request
  validates_numericality_of :jobs_per_request, :only_integer => true

  key :time_per_sample, :process_memory, :qos

  def name
    "#{self.time_per_sample}-#{self.process_memory}-#{self.qos}"
  end

end
