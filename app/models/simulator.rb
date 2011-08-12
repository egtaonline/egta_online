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
  field :parameter_hash, :type => Hash, :default => {}
  validates_presence_of :name, :version
  validates_uniqueness_of :version, :scope => :name
  has_many :profiles, :dependent => :destroy
  has_many :schedulers, :dependent => :destroy
  has_many :games
  after_create :setup_simulator

  def location
    File.join(Rails.root,"simulator_uploads", fullname)
  end

  def fullname
    name+"-"+version
  end

  def setup_simulator
    begin
      if setup == false
        update_attribute(:setup, true)
        puts location
        system("rm -rf #{location}/#{name}")
        puts "removed"
        system("unzip -uqq #{simulator_source.path} -d #{location}")
        puts "unzipped"
        parameters = Hash.new
        File.open(location+"/"+name+"/simulation_spec.yaml") do |io|
          parameters = YAML.load(io)["web parameters"]
          parameters.each_pair {|key, entry| parameters[key] = "#{entry}"}
          update_attribute(:parameter_hash, parameters)
        end
        Resque.enqueue(SimulatorInitializer, self.id)
      else
        return
      end
    rescue
      errors.add(:simulator_source, "has invalid parameters")
    end
  end
end
