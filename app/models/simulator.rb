require 'carrierwave/orm/mongoid'
# This model class represents a Game server

class Simulator
  include Mongoid::Document

  mount_uploader :simulator_source, SimulatorUploader
  field :parameter_fields, :type => Array
  field :name
  field :description
  field :version
  field :setup, :type => Boolean, :default => false
  field :strategy_array, :type => Array
  validates_presence_of :name, :version
  validates_uniqueness_of :version, :scope => :name
  has_many :games, :dependent => :destroy
  validate :setup_simulator
  after_create :set_setup_to_true

  def parameters
    param_hash = Hash.new
    self.parameter_fields.each { |param| param_hash[param] = self[param] }
    param_hash
  end

  def parameters=(param_hash)
    self.parameter_fields = param_hash.keys
    self.parameter_fields.each { |param| self[param] = param_hash[param] }
  end

  def self.inputs
    @inputs ||= [Hash[:name => "name", :type => "text_field"], Hash[:name => "version", :type => "text_field"], Hash[:name => "description", :type => "text_area"], Hash[:name => "simulator_source", :type => "file_field"]]
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

  def strategy_exists?(strategy_name)
    strategy_array.include?(strategy_name)
  end

  def add_strategy_by_name(strategy_name)
    self.strategy_array = Array.new if self.strategy_array == nil
    self.strategy_array << strategy_name unless self.strategy_array.include?(strategy_name)
    puts strategy_name
    puts self.strategy_array
  end

  def delete_strategy_by_name(strategy_name)
    self.strategy_array.delete(strategy_name)
  end
end
