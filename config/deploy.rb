require 'bundler/capistrano'
require 'capistrano/ext/multistage'
#require 'puma/capistrano'

load "config/recipes/base"
load "config/recipes/nginx"
load "config/recipes/nodejs"
load "config/recipes/rbenv"
load "config/recipes/mongodb"
load "config/recipes/redis"
load "config/recipes/foreman"
load "config/recipes/puma"
#load 'deploy/assets'

set :stages, %w(staging production)
set :default_stage, 'staging'
set :use_sudo, false

set :scm, 'git'
set :application, 'egtaonline'

default_run_options[:pty] = true
set :ssh_options, {:forward_agent => true}

namespace :web do
  desc "Disable requests to the app, show maintenance page"
  task :disable, roles: :web do
    run "cp #{current_path}/public/maintenance.html  #{shared_path}/system/maintenance.html"
  end

  desc "Re-enable the web server by deleting any maintenance file"
  task :enable, roles: :web do
    run "rm #{shared_path}/system/maintenance.html"
  end
end