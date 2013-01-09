require 'bundler/capistrano'
require 'capistrano/ext/multistage'

load "config/recipes/base"
load "config/recipes/nginx"
load "config/recipes/nodejs"
load "config/recipes/rbenv"
load "config/recipes/mongodb"
load "config/recipes/redis"
load "config/recipes/foreman"
load "config/recipes/puma"
load 'deploy/assets'

set :stages, %w(staging production)
set :default_stage, 'staging'
set :rails_env, 'production'
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, 'git'
set :application, 'egtaonline'

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

after 'deploy', 'deploy:cleanup'
# server "d-108-249.eecs.umich.edu", :web, :app, :db, primary: true
#
# set :user, "deployment"
# set :application, "egtaonline"
# set :deploy_to, "/home/deployment"
#
# set :scm, :git
set :repository,  "git@github.com:egtaonline/egta_online.git"
# set :migrate_target,  :current
# set :ssh_options,     { forward_agent: true }
# set :rails_env,       "production"
# set :normalize_asset_timestamps, false
#
# set(:latest_release)  { fetch(:current_path) }
# set(:release_path)    { fetch(:current_path) }
# set(:current_release) { fetch(:current_path) }
#
# set(:current_revision)  { capture("cd #{current_path}; git rev-parse --short HEAD").strip }
# set(:latest_revision)   { capture("cd #{current_path}; git rev-parse --short HEAD").strip }
# set(:previous_revision) { capture("cd #{current_path}; git rev-parse --short HEAD@{1}").strip }
#
# default_environment["RAILS_ENV"] = 'production'
#
# default_run_options[:pty] = true
#
# namespace :deploy do
#   desc "Deploy your application"
#   task :default do
#     update
#     restart
#   end
#
#   desc "Setup your git-based deployment app"
#   task :setup, except: { no_release: true } do
#     dirs = [deploy_to, shared_path]
#     dirs += shared_children.map { |d| File.join(shared_path, d) }
#     run "#{try_sudo} mkdir -p #{dirs.join(' ')} && #{try_sudo} chmod g+w #{dirs.join(' ')}"
#     run "git clone #{repository} #{current_path}"
#   end
#
#   task :cold do
#     update
#   end
#
#   task :update do
#     transaction do
#       update_code
#     end
#   end
#
#   desc "Update the deployed code."
#   task :update_code, except: { no_release: true } do
#     run "cd #{current_path}; git fetch origin; git reset --hard #{branch}"
#     finalize_update
#   end
#
#   desc "Update the database (overwritten to avoid symlink)"
#   task :migrations do
#     transaction do
#       update_code
#     end
#     restart
#   end
#
#   task :finalize_update, except: { no_release: true } do
#     # mkdir -p is making sure that the directories are there for some SCM's that don't
#     # save empty folders
#     run <<-CMD
#       rm -rf #{latest_release}/log #{latest_release}/public/system #{latest_release}/tmp/pids #{latest_release}/simulator_uploads &&
#       mkdir -p #{latest_release}/log
#       mkdir -p #{latest_release}/public &&
#       mkdir -p #{latest_release}/tmp &&
#       ln -s #{shared_path}/log #{latest_release}/log &&
#       ln -s #{shared_path}/system #{latest_release}/public/system &&
#       ln -s #{shared_path}/pids #{latest_release}/tmp/pids &&
#       ln -s #{shared_path}/simulator_uploads #{latest_release}/simulator_uploads &&
#       ln -sf #{shared_path}/mongoid.yml #{latest_release}/config/mongoid.yml
#     CMD
#
#     if fetch(:normalize_asset_timestamps, true)
#       stamp = Time.now.utc.strftime("%Y%m%d%H%M.%S")
#       asset_paths = fetch(:public_children, %w(images stylesheets javascripts)).map { |p| "#{latest_release}/public/#{p}" }.join(" ")
#       run "find #{asset_paths} -exec touch -t #{stamp} {} ';'; true", env: { "TZ" => "UTC" }
#     end
#   end
#
#   namespace :rollback do
#     desc "Moves the repo back to the previous version of HEAD"
#     task :repo, except: { no_release: true } do
#       set :branch, "HEAD@{1}"
#       deploy.default
#     end
#
#     desc "Rewrite reflog so HEAD@{1} will continue to point to at the next previous release."
#     task :cleanup, except: { no_release: true } do
#       run "cd #{current_path}; git reflog delete --rewrite HEAD@{1}; git reflog delete --rewrite HEAD@{1}"
#     end
#
#     desc "Rolls back to the previously deployed version."
#     task :default do
#       rollback.repo
#       rollback.cleanup
#     end
#   end
# end
#
# def run_rake(cmd)
#   run "cd #{current_path}; #{rake} #{cmd}"
# end
#
# namespace :deploy do
#   desc "Disable requests to the app, show maintenance page"
#   web.task :disable, roles: :web do
#     run "cp #{current_path}/public/maintenance.html  #{shared_path}/system/maintenance.html"
#   end
#
#   desc "Re-enable the web server by deleting any maintenance file"
#   web.task :enable, roles: :web do
#     run "rm #{shared_path}/system/maintenance.html"
#   end
# end
#