set :user, 'vagrant'
set :deploy_to, "/home/#{user}/#{application}"

server 'vagrant', :web, :app, :db, primary: true
set :deploy_via, :copy
set :copy_strategy, :export
set :repository, '.'
set :rails_env, 'production'