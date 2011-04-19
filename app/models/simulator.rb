require 'carrierwave/orm/mongoid'
# This model class represents a Game server

class Simulator
  include Mongoid::Document

  mount_uploader :simulator, SimulatorUploader
  field :parameters
  field :name
  field :description
  field :version
  validates_presence_of :name, :version
  validates_uniqueness_of :version, :scope => :name
  embeds_many :strategies
  has_and_belongs_to_many :server_proxies
  has_many :games, :dependent => :destroy

  def location
    File.dirname(__FILE__)+"/../../simulators/"+fullname
  end

  def fullname
    name+"-"+version
  end

  def setup_simulator
    system("unzip -u #{simulator.path} -d #{location}")
    self.parameters = File.open(location+"/"+name+"/simulation_spec.yaml"){|io| io.read}
    output = "Simulator setup on main.\n"
    self.save!
    server_proxies.each {|server_proxy| output += server_proxy.setup_simulator(self)}
    return output
  end

  def strategy_exists?(strategy_name)
    strategies.include?(strategy_name)
  end
end
