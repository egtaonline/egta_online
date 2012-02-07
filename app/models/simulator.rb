class Simulator
  include Mongoid::Document
  include RoleManipulator

  mount_uploader :simulator_source, SimulatorUploader
  field :name
  field :description
  field :version
  field :setup, :type => Boolean, :default => false
  embeds_many :roles, :as => :role_owner
  field :parameter_hash, :type => Hash, :default => {}
  validates_presence_of :name, :version
  validates_uniqueness_of :version, :scope => :name
  has_many :profiles, :dependent => :destroy
  has_many :schedulers, :dependent => :destroy
  has_many :games, :dependent => :destroy
  validate :simulator_setup, :on => :create

  def simulator_setup
    if setup == false
      system("rm -rf #{location}/#{name}")
      begin
        system("unzip -uqq #{simulator_source.path} -d #{location}")
      rescue
        errors.add(:simulator_source, "Upload could not be unzipped.")
        return
      end
      if File.exists?(location+"/"+name+"/simulation_spec.yaml") == false
        errors.add(:simulator_source, "Upload was missing a simulation_spec.yaml configuration file.")
        return
      else
        begin
          parameters = Hash.new
          File.open(location+"/"+name+"/simulation_spec.yaml") do |io|
            parameters = YAML.load(io)["web parameters"]
            parameters.each_pair {|key, entry| parameters[key] = "#{entry}"}
          end
          self.parameter_hash = parameters
          Resque.enqueue(SimulatorInitializer, self.id)
          self.setup = true
        rescue
          errors.add(:simulator_source, "Upload had a malformed simulation_spec.yaml file.")
        end
      end
    end
  end

  def location
    File.join(Rails.root,"simulator_uploads", fullname)
  end

  def fullname
    name+"-"+version
  end

  def remove_strategy(role, strategy)
    super
    profiles.each {|profile| if profile.contains_strategy?(role, strategy); profile.destroy; end}
  end
end