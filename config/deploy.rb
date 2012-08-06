require 'bundler/capistrano'

load "config/recipes/base"
load "config/recipes/nginx"
load "config/recipes/unicorn"
load "config/recipes/nodejs"
load "config/recipes/rbenv"

server "d-108-249.eecs.umich.edu", :web, :app, :db, primary: true

set :user, "deployment"
set :application, "egtaonline"
set :deploy_to, "/home/deployment"

set :scm, :git
set :repository,  "git@github.com:egtaonline/egta_online.git"
set :branch, "origin/master"

default_run_options[:pty] = true
namespace :deploy do
  desc "Deploy app"
  task :default do
    update
    restart
    cleanup
  end

  desc "Setup a GitHub-style deployment."
  task :setup, :except => { :no_release => true } do
    run "git clone #{repository} #{current_path}"
  end

  desc "Update the deployed code."
  task :update_code, :except => { :no_release => true } do
    run "cd #{current_path}; git fetch origin; git reset --hard #{branch}; bundle --without development test"
  end

  namespace :rollback do
    desc "Rollback"
    task :default do
      code
    end

    desc "Rollback a single commit."
    task :code, :except => { :no_release => true } do
      set :branch, "HEAD^"
      default
    end
  end

  desc "Make all the symlinks"
  task :symlink, :roles => :app, :except => { :no_release => true } do
    set :normal_symlinks, %w(
      simulator_uploads
    )

    commands = normal_symlinks.map do |path|
      "rm -rf #{current_path}/#{path} && \
       ln -s #{shared_path}/#{path} #{current_path}/#{path}"
    end

    # set :weird_symlinks, {
    #   "path_on_disk" => "path_to_symlink"
    # }
    commands += ["rm -rf #{current_path}/public/system && rm -rf #{current_path}/config/mongoid.yml && \
     ln -s #{shared_path}/system #{current_path}/public/system && ln -s #{shared_path}/mongoid.yml #{current_path}/config/mongoid.yml"]
    # end

    # needed for some of the symlinks
    run "mkdir -p #{current_path}/tmp && \
         mkdir -p #{current_path}/log && \
         mkdir -p #{current_path}/simulator_uploads"

    run <<-CMD
      cd #{current_path} &&
      #{commands.join(" && ")}
    CMD
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

namespace :foreman do
  desc "Start the application services"
  task :start, :roles => :app do
    sudo "start #{application}1"
    sudo "start #{application}2"
  end

  desc "Stop the application services"
  task :stop, :roles => :app do
    sudo "stop #{application}2"
    sudo "stop #{application}1"
  end

  desc "Restart the application services"
  task :restart, :roles => :app do
    run "sudo stop #{application}2; sudo stop #{application}1; sudo start #{application}1; sudo start #{application}2"
  end

  desc "Display logs for a certain process - arg example: PROCESS=web-1"
  task :logs, :roles => :app do
    run "cd #{current_path}/log && cat #{ENV["PROCESS"]}.log"
  end

  desc "Export the Procfile to upstart scripts"
  task :export, :roles => :app do
    # 5 resque workers, 1 resque scheduler
    run "cd /home/deployment/current && #{sudo} bundle exec foreman export upstart /etc/init -a #{application} -u #{user} -l #{shared_path}/log  -f /home/deployment/current/Procfile"
  end
end

namespace :deploy do
  namespace :assets do
    task :precompile, :roles => :web, :except => { :no_release => true } do
      from = source.next_revision(current_revision)
      if capture("cd #{latest_release} && #{source.local.log(from)} vendor/assets/ app/assets/ | wc -l").to_i > 0
        run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile}
      else
        logger.info "Skipping asset pre-compilation because there were no asset changes"
      end
    end
  end
end

before 'deploy:symlink', 'deploy:assets:precompile'
after 'deploy:assets:precompile', 'foreman:restart'
after "deploy", "deploy:cleanup"