namespace :puma do
  desc "Start puma"
  task :start, :roles => :app do
    puma_env = fetch(:rack_env, fetch(:rails_env, "production"))
    run "cd #{current_path} && #{fetch(:bundle_cmd, "bundle")} exec puma -d -e #{puma_env} -b 'unix://#{shared_path}/sockets/puma.sock' -S #{shared_path}/sockets/puma.state --control 'unix://#{shared_path}/sockets/pumactl.sock'", :pty => false
  end

  desc "Stop puma"
  task :stop, :roles => :app do
    run "cd #{current_path} && #{fetch(:bundle_cmd, "bundle")} exec pumactl -S #{shared_path}/sockets/puma.state stop"
  end

  desc "Restart puma"
  task :restart, :roles => :app do
    run "cd #{current_path} && #{fetch(:bundle_cmd, "bundle")} exec pumactl -S #{shared_path}/sockets/puma.state restart"
  end
  after "deploy:stop", "puma:stop"
  after "deploy:start", "puma:start"
  after "deploy:restart", "puma:restart"
end
