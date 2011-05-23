$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require "rvm/capistrano"
require 'bundler/capistrano'
set :rvm_ruby_string, '1.9.2@egta'

set :application, "EGTMAS Web Interface"
set :repository,  "git@github.com:bcassell/EGTMAS-Web-Interface.git"
set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :deploy_to, "/home/bcassell/Deployment"
role :web, "d-108-249.eecs.umich.edu"                          # Your HTTP server, Apache/etc
role :app, "d-108-249.eecs.umich.edu"                          # This may be the same as your `Web` server
role :db,  "d-108-249.eecs.umich.edu", :primary => true # This is where Rails migrations will run

namespace :deploy do
  task :stop_god do
    run "/usr/local/rvm/bin/bootup_god terminate" rescue nil
  end

  task :start_god do
    run "/usr/local/rvm/bin/bootup_god -c #{current_release}/config/egta.god"
  end

  desc "Restart Application"
  task :restart, :roles => :app do
    before "deploy:symlink", "deploy:stop_god"
  end
end

before 'deploy:update_code', 'deploy:stop_god'
after "deploy:symlink", "deploy:start_god"