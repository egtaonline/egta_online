data_worker: cd /home/deployment/egtaonline/current && RAILS_ENV=production bundle exec sidekiq -q high_concurrency
profile_space_worker: cd /home/deployment/egtaonline/current && RAILS_ENV=production bundle exec sidekiq -c 1 -q profile_space
backend_worker: cd /home/deployment/egtaonline/current && RAILS_ENV=production bundle exec sidekiq -c 1 -q backend
scheduler: cd /home/deployment/egtaonline/current && RAILS_ENV=production bundle exec clockwork clockwork.rb