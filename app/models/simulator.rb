require 'carrierwave/orm/mongoid'
# This model class represents a Game server

class Simulator
  include Mongoid::Document
  include StrategyManipulation

  mount_uploader :simulator_source, SimulatorUploader
  field :name
  field :description
  field :version
  field :setup, :type => Boolean, :default => false
  field :strategy_array, :type => Array, :default => []
  validates_presence_of :name, :version
  validates_uniqueness_of :version, :scope => :name
  has_many :profiles, :dependent => :destroy
  has_many :schedulers, :dependent => :destroy
  has_many :run_time_configurations
  validate :setup_simulator
  after_create :set_setup_to_true

  def set_setup_to_true
    if setup == false
      self.update_attributes(:setup => true)
    end
  end

  def location
    ROOT_PATH+"/simulators/"+fullname
  end

  def fullname
    name+"-"+version
  end

  def setup_simulator
    begin
      if setup == false
        system("rm -rf #{location}/#{name}")
        system("unzip -uqq #{simulator_source.path} -d #{location}")
        temp_hash = Hash.new
        File.open(location+"/"+name+"/simulation_spec.yaml"){|io| self.parameters = YAML.load(io)["web parameters"]}
        sp = ServerProxy.new
        sp.start
        sp.setup_simulator(self)
      else
        return
      end
    rescue
      errors.add(:simulator_source, "couldn't be uploaded to destination")
    end
  end
end
