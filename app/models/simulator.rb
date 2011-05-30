require 'carrierwave/orm/mongoid'
# This model class represents a Game server

class Simulator
  include Mongoid::Document
  include StrategyManipulation

  mount_uploader :simulator_source, SimulatorUploader
  field :parameter_fields, :type => Array
  field :name
  field :description
  field :version
  field :setup, :type => Boolean, :default => false
  field :strategy_array, :type => Array
  validates_presence_of :name, :version
  validates_uniqueness_of :version, :scope => :name
  has_many :profiles, :dependent => :destroy
  has_many :schedulers, :dependent => :destroy
  has_one :default_configuration, :class_name => "RunTimeConfiguration"
  validate :setup_simulator
  after_create :set_setup_to_true

  def run_time_configurations
    profiles.reduce([]) {|ret, profile| ret << profile.run_time_configuration}.uniq
  end

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
