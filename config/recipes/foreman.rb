namespace :foreman do
  desc "Start the application services"
  task :start, roles: :app do
    sudo "#{sudo} start sidekiq"
  end

  desc "Stop the application services"
  task :stop, roles: :app do
    sudo "#{sudo} stop sidekiq"
  end

  desc "Restart the application services"
  task :restart, roles: :app do
    run "#{sudo} stop sidekiq; #{sudo} start sidekiq"
  end

  desc "Display logs for a certain process - arg example: PROCESS=web-1"
  task :logs, roles: :app do
    run "cd #{current_path}/log && cat #{ENV["PROCESS"]}.log"
  end

  desc "Export the Procfile to upstart scripts"
  task :export, roles: :app do
    run "cd /home/#{user}/#{application}/current && #{sudo} bundle exec foreman export upstart /etc/init -a sidekiq -u #{user} -l #{shared_path}/log  -f /home/#{user}/#{application}/current/Procfile"
  end

  after 'deploy:finalize_update', 'foreman:export'
  after 'deploy:finalize_update', 'foreman:restart'
end