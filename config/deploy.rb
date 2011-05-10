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

namespace :deploy do
  task :start, :roles => :app do
    after "deploy:symlink", "daemons:start"
  end

  task :stop, :roles => :app do
    before "deploy:symlink", "daemons:stop"
  end

  desc "Restart Application"
  task :restart, :roles => :app do
    before "deploy:symlink", "daemons:stop"
    after "deploy:symlink", "daemons:start"
  end
end

namespace :daemons do

  desc "Start Daemons"
  task :start, :roles => :app do
    run "god -c #{current_release}/config/egta.god"
  end

  desc "Stop Daemons"
  task :stop, :roles => :app do
    run "god terminate"
  end

  desc "Restart Daemons"
  task :restart, :roles => :app do
    run "god terminate"
    run "god -c #{current_release}/config/egta.god"
  end
end