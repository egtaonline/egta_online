# This model class represents games and corresponding Profiles are automatically
# generated given possible strategies

class Game
  include Mongoid::Document
  field :description
  field :parameter_fields, :type => Array
  field :name
  field :strategy_array, :type => Array, :default => []
  validates_presence_of :name
  validates_uniqueness_of :name
  field :size, :type => Integer
  validates_numericality_of :size, :integer_only => true


  belongs_to :simulator
  has_many :profiles, :dependent => :destroy
  has_many :schedulers, :dependent => :destroy
  has_many :features

  def self.edit_inputs
    nil
  end

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
    @inputs ||= [Hash[:name => "name", :type => "text_field"], Hash[:name => "description", :type => "text_area"]]
  end

  # Add Strategy to a Game
  def add_strategy_by_name(strategy_name)
    strategy_array << strategy_name
    strategy_array.uniq!
    ensure_profiles
  end

  # Remove Strategy from a Game
  def delete_strategy_by_name(strategy_name)
    profiles.each {|profile| if profile.contains_strategy?(strategy_name); profile.destroy; end}
    strategy_array.delete(strategy_name)
    self.save!
  end
end
