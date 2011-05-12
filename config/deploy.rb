$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require "rvm/capistrano"
require 'bundler/capistrano'
set :rvm_ruby_string, '1.9.2'

set :application, "EGTMAS Web Interface"
set :repository,  "git@github.com:bcassell/EGTMAS-Web-Interface.git"
set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :deploy_to, "/home/bcassell/Deployment"
role :web, "d-108-249.eecs.umich.edu"                          # Your HTTP server, Apache/etc
role :app, "d-108-249.eecs.umich.edu"                          # This may be the same as your `Web` server
role :db,  "d-108-249.eecs.umich.edu", :primary => true # This is where Rails migrations will run

namespace :god do
  task :start, :roles => :app do
    god_config_file = "#{latest_release}/config/egta.god"
    sudo "god --log-level debug -c #{god_config_file}"
  end
  task :stop, :roles => :app do
    sudo "god terminate" rescue nil
  end
  task :restart, :roles => :app do
    god.stop
    god.start
  end
  task :status, :roles => :app do
    sudo "god status"
  end
  task :log, :roles => :app do
    sudo "tail -f /var/log/messages"
  end
  task :deploy_config, :roles => :app do
    god_config_file = "#{latest_release}/config/omt.god"
    god_script_template = File.dirname(__FILE__) + "/deploy/templates/omt.god.erb.rb"
    data = ERB.new(IO.read(god_script_template)).result(binding)
    sudo "god load #{god_config_file}"
  end
  task :redeploy, :roles => :app do
    god.deploy_config
    god.load_config
  end
end