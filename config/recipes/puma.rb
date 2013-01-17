after "deploy:stop", "puma:stop"
after "deploy:start", "puma:start"
after "deploy:restart", "puma:restart"

namespace :puma do
  desc "Start puma"
  task :start do
    run "cd #{current_path} && RAILS_ENV=#{stage} bundle exec puma -e #{stage} -b 'unix://#{shared_path}/sockets/puma.sock' -S #{shared_path}/sockets/puma.state --control 'unix://#{shared_path}/sockets/pumactl.sock' >> #{shared_path}/log/puma-#{stage}.log 2>&1 &", :pty => false
  end

  desc "Stop puma"
  task :stop do
    run "cd #{current_path} && RAILS_ENV=#{stage} bundle exec pumactl -S #{shared_path}/sockets/puma.state stop"
  end

  desc "Restart puma"
  task :restart do
    run "cd #{current_path} && RAILS_ENV=#{stage} bundle exec pumactl -S #{shared_path}/sockets/puma.state restart"
  end

end
