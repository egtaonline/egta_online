class Simulator
  require 'find'

  include Mongoid::Document
  include RoleManipulator::Base
  mount_uploader :simulator_source, SimulatorUploader

  embeds_many :roles, as: :role_owner
  has_many :profiles, dependent: :destroy do
    def with_role_and_strategy(role, strategy)
      where(assignment: Regexp.new("#{role}:( \\d+ \\w+,)* \\d+ #{strategy}(,|;|\\z)"))
    end
  end
  has_many :schedulers, dependent: :destroy
  has_many :games, dependent: :destroy

  field :name
  field :description
  field :version
  field :configuration, type: Hash, default: {}
  field :email

  validates :email, presence: true, format: { with: /^([^@\s]+)@((?:[-a-z0-9]+.)+[a-z]{2,})$/i, message: 'does not match the expected format' }
  validates :name, presence: true, format: { with: /\A\w+\z/, message: 'can contain only letters, numbers, and underscores'}
  validates :version, presence: true, uniqueness: { scope: :name }
  before_validation(if: :simulator_source_changed?){ FileUtils.rm_rf location }
  validate :simulator_setup, if: :simulator_source_changed?

  def find_or_create_profile(configuration, assignment)
    profiles.find_or_create_by(configuration: configuration, assignment: assignment)
  end

  def simulator_setup
    begin
      system("unzip -uqq #{simulator_source.path} -d #{location}")
    rescue
      errors.add(:simulator_source, "Upload could not be unzipped.")
      return
    end
    dirs = Dir.entries(location) - [".", "..", "__MACOSX"]
    if dirs.size != 1 || !File.directory?("#{location}/#{dirs[0]}")
      errors.add(:simulator_source, "did not unzip to a single folder")
    elsif !File.exists?("#{location}/#{dirs[0]}/script/batch")
      errors.add(:simulator_source, "did not find script/batch within #{location}/#{dirs[0]}")
    end
    Find.find(location) do |path|
      if File.basename(path) == "defaults.json"
        begin
          self.configuration = Oj.load_file(path)['configuration']
          Resque.enqueue(SimulatorInitializer, self.id)
        rescue SyntaxError => se
          errors.add(:simulator_source, "had a malformed defaults.json file.")
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

  def remove_strategy(role_name, strategy_name)
    schedulers.each do |scheduler|
      scheduler.remove_strategy(role_name, strategy_name)
    end
    super
    profiles.with_role_and_strategy(role_name, strategy_name).destroy_all
  end

  def remove_role(role_name)
    schedulers.each do |scheduler|
      scheduler.remove_role(role_name)
    end
    super
    profiles.where(assignment: Regexp.new("#{role_name}: ")).destroy_all
  end
end