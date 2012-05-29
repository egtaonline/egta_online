class Simulator
  require 'find'
  
  include Mongoid::Document
  include RoleManipulator

  mount_uploader :simulator_source, SimulatorUploader

  embeds_many :roles, :as => :role_owner
  has_many :profiles, :dependent => :destroy do
    def with_role_and_strategy(role, strategy)
      where(:name => Regexp.new("#{role}:( \\d+ \\w+,)* \\d+ #{strategy}(,|;|\\z)"))
    end
  end
  has_many :schedulers, :dependent => :destroy
  has_many :games, :dependent => :destroy

  field :name
  field :description
  field :version
  field :parameter_hash, :type => Hash, :default => {}
  field :email
  
  validates :email, :email_format => {:message => 'does not match the expected format'}
  validates :name, :presence => true, :format => {:with => /\A\w+\z/, :message => 'can contain only letters, numbers, and underscores'}
  validates :version, :presence => true, :uniqueness => { :scope => :name }
  before_validation(:if => :simulator_source_changed?){ FileUtils.rm_rf location }
  validate :simulator_setup, :if => :simulator_source_changed?

  def simulator_setup
    begin
      system("unzip -uqq #{simulator_source.path} -d #{location}")
    rescue
      errors.add(:simulator_source, "Upload could not be unzipped.")
      return
    end
    Find.find(location) do |path|
      if File.basename(path) == "simulation_spec.yaml"
        begin
          parameters = Hash.new
          File.open(path) do |io|
            parameters = YAML.load(io)["web parameters"]
            parameters.each_pair {|key, entry| parameters[key] = "#{entry}"}
          end
          self.parameter_hash = parameters
          Resque.enqueue(SimulatorInitializer, self.id)
        rescue
          errors.add(:simulator_source, "had a malformed simulation_spec.yaml file.")
        end
        return
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
    schedulers.each do |scheduler|
      scheduler.remove_strategy(role, strategy)
    end
    super
    profiles.with_role_and_strategy(role, strategy).destroy_all
  end
  
  def remove_role(role)
    schedulers.each do |scheduler|
      scheduler.remove_role(role)
    end
    super
    profiles.where(:name => Regexp.new("#{role}: ")).destroy_all
  end
end