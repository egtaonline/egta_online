require 'carrierwave/orm/mongoid'
# This model class represents a Game server

class Simulator
  include Mongoid::Document

  mount_uploader :simulator, SimulatorUploader
  field :parameters
  field :name
  field :description
  field :version
  field :strategies, :type => Array, :default => Array.new

  validates_presence_of :name, :version
  validates_uniqueness_of :version, :scope => :name

  references_many :games
  referenced_in :account

  def setup_simulator
    Net::SCP::upload!(account.host, account.username, simulator.path, "#{DEPLOY_PATH}/#{name}-#{version}.zip")
    output = ""
    Net::SSH.start(account.host, account.username) do |ssh|
      output = ssh.exec!("cd #{DEPLOY_PATH}; unzip #{name}-#{version}.zip -d #{name}-#{version}; chgrp -R wellman #{name}-#{version}; chmod -R ug+wrx #{name}-#{version}; rm #{name}-#{version}.zip")
    end
    self.parameters = Net::SCP::download!(account.host, account.username, "#{DEPLOY_PATH}/#{name}-#{version}/#{name}/simulation_spec.yaml")
    self.save
    return output
  end

  def strategy_exists?(strategy_name)
    strategies.include?(strategy_name)
  end
end
