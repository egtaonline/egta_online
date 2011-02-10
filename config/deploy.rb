$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require "rvm/capistrano"
set :rvm_ruby_string, 'jruby-1.6.0.RC2'


set :application, "EGTMAS Web Interface"
set :repository,  "git@github.com:bcassell/EGTMAS-Web-Interface.git"
set :branch, "mongoid"
set :scm, :git
set :deploy_via, :remote_cache
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :deploy_to, "/home/bcassell/Deployment"
role :web, "d-108-249.eecs.umich.edu"                          # Your HTTP server, Apache/etc
role :app, "d-108-249.eecs.umich.edu"                          # This may be the same as your `Web` server
role :db,  "d-108-249.eecs.umich.edu", :primary => true # This is where Rails migrations will run

namespace :deploy do
  task :start, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end

  task :stop, :roles => :app do
    # Do nothing.
  end

  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end
end

before "deploy:symlink", "daemons:stop"
after "deploy:symlink", "daemons:start"
namespace :daemons do

  desc "Start Daemons"
  task :start, :roles => :app do
    run "rvm 1.9.2"
    run "#{current_release}/lib/daemons/periodic_daemon_ctl start"
    run "#{current_release}/lib/daemons/stalker_daemon.rb start"
    run "rvm jruby-1.6.0.RC2"
  end

  desc "Stop Daemons"
  task :stop, :roles => :app do
    run "rvm 1.9.2"
    run "#{current_release}/lib/daemons/periodic_daemon_ctl stop"
    run "#{current_release}/lib/daemons/stalker_daemon.rb stop"
    run "rvm jruby-1.6.0.RC2"
  end

  desc "Restart Daemons"
  task :restart, :roles => :app do
    run "rvm 1.9.2"
    run "#{current_release}/lib/daemons/periodic_daemon_ctl restart"
    run "#{current_release}/lib/daemons/stalker_daemon.rb restart"
    run "rvm jruby-1.6.0.RC2"
  end
end