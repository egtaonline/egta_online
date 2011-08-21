$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require "rvm/capistrano"
require 'bundler/capistrano'
set :rvm_ruby_string, 'ruby-1.9.2'
set :rvm_type, :user
set :application, "EGTMAS Web Interface"
set :repository,  "git@github.com:egtaonline/egta_online.git"
set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :deploy_to, "/home/deployment"
role :web, "deployment@d-108-249.eecs.umich.edu"                          # Your HTTP server, Apache/etc
role :app, "deployment@d-108-249.eecs.umich.edu"                          # This may be the same as your `Web` server
role :db,  "deployment@d-108-249.eecs.umich.edu", :primary => true # This is where Rails migrations will run

namespace :deploy do
  task :make_upload_dir do
    run "mkdir -p #{current_release}/simulator_uploads"
  end

  task :start, :roles => :app do
    run "touch #{current_release}/tmp/restart"
  end

  task :stop_god do
    run "/home/deployment/.rvm/bin/bootup_god terminate" rescue nil
    run "cd #{current_path} && rake resque:stop_workers RAILS_ENV=production"
  end

  task :start_god do
    run "/home/deployment/.rvm/bin/bootup_god -c #{current_release}/config/egta.god"
  end

  desc "Restart Application"
  task :restart, :roles => :app do
    before "deploy:symlink", "deploy:stop_god"
    run "touch #{current_release}/tmp/restart.txt"
  end

  desc "precompile the assets"
  task :precompile_assets, :roles => :web, :except => { :no_release => true } do
    run "cd #{current_path}; rm -rf public/assets/*"
    run "cd #{current_path}; RAILS_ENV=production bundle exec rake assets:precompile"
  end

  desc "Disable requests to the app, show maintenance page"
  web.task :disable, :roles => :web do
    run "cp #{current_path}/public/maintenance.html  #{shared_path}/system/maintenance.html"
  end

  desc "Re-enable the web server by deleting any maintenance file"
  web.task :enable, :roles => :web do
    run "rm #{shared_path}/system/maintenance.html"
  end
end

before 'deploy:update_code', 'deploy:stop_god'
after 'deploy:update_code', 'deploy:make_upload_dir'
before 'deploy:symlink', 'deploy:precompile_assets'
after "deploy:symlink", "deploy:start_god"