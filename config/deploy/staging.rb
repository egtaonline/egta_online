set :user, 'vagrant'
set :rails_env, 'staging'
server 'vagrant', :web, :app, :db, primary: true
set :deploy_via, :copy
ssh_options[:keys] = `vagrant ssh-config | grep IdentityFile`.split.last
set :repository, '.'
set :branch, 'experimental'
set :deploy_to, "/home/#{user}/#{application}"