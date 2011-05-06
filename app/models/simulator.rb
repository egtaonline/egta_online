require 'carrierwave/orm/mongoid'
# This model class represents a Game server

class Simulator
  include Mongoid::Document

  mount_uploader :simulator, SimulatorUploader
  field :parameters
  field :name
  field :description
  field :version
  field :setup, :type => Boolean, :default => false
  field :strategies, :type => Array, :default => []
  validates_presence_of :name, :version
  validates_uniqueness_of :version, :scope => :name
  has_many :games, :dependent => :destroy
  validate :setup_simulator
  after_create :set_setup_to_true

  def set_setup_to_true
    self.update_attributes(:setup => true)
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
        system("unzip -u #{simulator.path} -d #{location}")
        puts "unzip"
        self.parameters = File.open(location+"/"+name+"/simulation_spec.yaml"){|io| io.read}
        sp = ServerProxy.new
        sp.start
        puts "start"
        sp.setup_simulator(self)
        puts "simulator setup"
      else
        return
      end
    rescue
      errors.add(:simulator, "couldn't be uploaded to nyx")
    end
  end

  def strategy_exists?(strategy_name)
    strategies.include?(strategy_name)
  end
end
