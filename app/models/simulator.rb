class Simulator
  include Mongoid::Document

  mount_uploader :simulator_source, SimulatorUploader
  field :name
  field :description
  field :version
  field :setup, type: Boolean, default: false
  field :role_strategy_hash, type: Hash, default: {}
  field :parameter_hash, type: Hash, default: {}
  validates_presence_of :name, :version
  validates_uniqueness_of :version, scope: :name
  has_many :profiles, dependent: :destroy
  has_many :schedulers, dependent: :destroy
  has_many :games, dependent: :destroy
  after_create :setup_simulator

  def add_strategy_by_name(role, strategy)
    role_strategy_hash[role] = [] if role_strategy_hash[role] == nil
    role_strategy_hash[role] << strategy
    hash = role_strategy_hash
    self.update_attribute(:role_strategy_hash, nil)
    self.update_attribute(:role_strategy_hash, hash)
  end
  
  def remove_strategy_by_name(role, strategy)
    role_strategy_hash[role].delete(strategy)
    hash = role_strategy_hash
    profiles.each {|profile| if profile.contains_strategy?(role, strategy); profile.destroy; end}
    self.update_attribute(:role_strategy_hash, nil)
    self.update_attribute(:role_strategy_hash, hash)
  end

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
