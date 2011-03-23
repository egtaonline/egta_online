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
  references_many :games, :dependent => :destroy

  def setup_simulator(account_id)
    account = Account.find(account_id)
    Net::SCP::upload!(account.host, account.username, simulator.path, "#{DEPLOY_PATH}/#{name}-#{version}.zip")
    output = ""
    Net::SSH.start(account.host, account.username) do |ssh|
      output = ssh.exec!("cd #{DEPLOY_PATH}; if test -e #{name}-#{version}; then echo exists; else unzip #{name}-#{version}.zip -d #{name}-#{version}; chgrp -R wellman #{name}-#{version}; chmod -R ug+wrx #{name}-#{version}; rm #{name}-#{version}.zip; fi")
    end
    self.parameters = Net::SCP::download!(account.host, account.username, "#{DEPLOY_PATH}/#{name}-#{version}/#{name}/simulation_spec.yaml")
    self.save
    return output
  end

  def strategy_exists?(strategy_name)
    strategies.include?(strategy_name)
  end
end
