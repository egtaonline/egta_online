set :user, 'vagrant'

server 'vagrant', :web, :app, :db, primary: true
set :deploy_to, "/home/#{user}/#{application}"
set :branch, "origin/experimental"