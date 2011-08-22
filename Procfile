mongo: mongod
redis: redis-server
profile_actions_worker: cd ~deployment/current && bundle exec rake environment resque:work QUEUE=profile_actions
nyx_actions_worker: cd ~deployment/current && bundle exec rake environment resque:work QUEUE=nyx_actions