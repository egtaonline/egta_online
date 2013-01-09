profile_actions_worker: bundle exec rake environment resque:work QUEUE=profile_actions
nyx_actions_worker: bundle exec rake environment resque:work QUEUE=nyx_actions
nyx_queuing_worker: bundle exec rake environment resque:work QUEUE=nyx_queuing
nyx_check_scheduler: bundle exec rake resque:scheduler
monitor_workers: bundle exec ruby lib/monitor_workers.rb