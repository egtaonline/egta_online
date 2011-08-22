mongo: mongod
redis: redis-server
profile_actions_worker: cd ~deployment/current && RAILS_ENV=production bundle exec rake environment resque:work QUEUE=profile_actions VVERBOSE=1
nyx_actions_worker: cd ~deployment/current && RAILS_ENV=production bundle exec rake environment resque:work QUEUE=nyx_actions VVERBOSE=1
nyx_check_scheduler: cd ~deployment/current && RAILS_ENV=production bundle exec rake resque:scheduler VERBOSE=1
